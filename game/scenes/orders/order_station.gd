extends Control
## Standalone 1440x900 GDD station. Scales inside the existing 960x540 workbench.

signal close_requested
signal order_accepted(order: Dictionary)
signal order_selected(order_id: String)
signal pause_requested(is_paused: bool)
signal restart_requested

const Manager = preload("res://scenes/orders/order_manager.gd")
const DESIGN_SIZE := Vector2(1440, 900)
const INK := Color("542c14")
const MUTED := Color("8b6041")
const PAPER := Color("ffedc0")
const GOLD := Color("df9b3e")
const GREEN := Color("6d5932")
const RED := Color("a64219")
const STATUS_NAMES := {
	"pending": ["Awaiting acceptance", "等待接单"],
	"accepted": ["Accepted · oven next", "已接单 · 待入炉"],
	"roasting": ["Roasting", "烤制中"],
	"preparing": ["Preparing", "料理中"],
	"ready_to_serve": ["Ready to serve", "待交付"],
}
const ICON_INDEX := {"duck": 0, "wrapper": 1, "greens": 2, "sauce": 3, "sugar": 4, "melon": 5, "hawthorn": 6, "scallion": 7}

var manager: Node
var embedded := false
var language := "en"
var paused := false
var _focused := true
var _owns_manager := false
var _canvas: Control
var _content: Control
var _queue: Control
var _font: SystemFont
var _heading_font: SystemFont
var _time_labels: Dictionary = {}
var _bars: Dictionary = {}
var _buttons: Dictionary = {}
var _message_label: Label
var _count_label: Label
var _detail_time: Label
var _detail_bar: ProgressBar
var _accept_button: Button
var _notice := ""
var _auto_elapsed := 0.0
var _auto_arrivals := false
var _atlas: Texture2D
var _panel_atlas: Texture2D
var _panel_tiles: Array[Texture2D] = []
var _background: Texture2D
var _textures: Dictionary = {}


func _ready() -> void:
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Microsoft YaHei", "PingFang SC", "Noto Sans CJK SC", "Segoe UI"])
	_font.allow_system_fallback = true
	_heading_font = SystemFont.new()
	_heading_font.font_names = PackedStringArray(["Georgia", "KaiTi", "STKaiti", "Noto Serif CJK SC"])
	_heading_font.allow_system_fallback = true
	_atlas = load("res://assets/ui/orders/ingredient_atlas.png")
	_panel_atlas = load("res://assets/ui/orders/panel_atlas.png")
	# Runtime atlas slicing and downsampling keep nine-slice borders proportional
	# to 56-80px controls, instead of folding oversized source borders together.
	var source: Image = _panel_atlas.get_image()
	var panel_size := Vector2i(source.get_width() / 2, source.get_height() / 2)
	for tile_index in range(4):
		var tile_image := source.get_region(Rect2i(Vector2i((tile_index % 2) * panel_size.x, (tile_index / 2) * panel_size.y), panel_size))
		tile_image.resize(256, 170, Image.INTERPOLATE_LANCZOS)
		_panel_tiles.append(ImageTexture.create_from_image(tile_image))
	_background = load("res://assets/ui/orders/order_counter_background.png")
	var portraits: Texture2D = load("res://assets/ui/orders/customer_portraits.png")
	var names := ["customer_lin", "customer_chen", "customer_mei"]
	for index in range(names.size()):
		var portrait := AtlasTexture.new()
		portrait.atlas = portraits
		portrait.region = Rect2(index * portraits.get_width() / 3.0, 0, portraits.get_width() / 3.0, portraits.get_height())
		_textures[names[index]] = portrait
	if manager == null:
		manager = Manager.new()
		manager.name = "OrderManager"
		add_child(manager)
		_owns_manager = true
	_connect_manager()
	_build()
	resized.connect(_fit)
	_fit()
	if manager.get_visible_orders().is_empty() and manager.catalog_error.is_empty():
		manager.create_order()
	_refresh()
	get_window().focus_entered.connect(_on_focus_entered)
	get_window().focus_exited.connect(_on_focus_exited)


func _connect_manager() -> void:
	manager.order_created.connect(_on_order_changed)
	manager.order_updated.connect(_on_order_changed)
	manager.order_selected.connect(_on_selected)
	manager.order_accepted.connect(_on_accepted)
	manager.order_expired.connect(_on_expired)
	manager.orders_reset.connect(_refresh)


func _process(delta: float) -> void:
	if paused or not _focused or not visible:
		return
	# An injected shared manager is advanced by the owning game, never twice here.
	if _owns_manager:
		manager.advance_time(delta)
	if _auto_arrivals:
		_auto_elapsed += delta
		if _auto_elapsed >= 18.0:
			_auto_elapsed = 0.0
			manager.create_order()
	_refresh_times()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_toggle_pause()
			get_viewport().set_input_as_handled()


func _fit() -> void:
	if _canvas == null:
		return
	var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	_canvas.scale = Vector2.ONE * factor
	_canvas.position = (size - DESIGN_SIZE * factor) / 2.0


func _build() -> void:
	_heading_font.font_names = PackedStringArray(["KaiTi", "STKaiti", "Noto Serif CJK SC"]) if language == "zh" else PackedStringArray(["Georgia", "Noto Serif", "DejaVu Serif"])
	for child in get_children():
		if child is Control:
			remove_child(child)
			child.queue_free()
	_buttons.clear()
	_canvas = Control.new()
	_canvas.name = "DesignCanvas"
	_canvas.size = DESIGN_SIZE
	add_child(_canvas)
	_picture(_canvas, _background, Rect2(0, 0, 1440, 900), false)
	_label(_canvas, _t("Magic Kitchen", "烤鸭卷制作"), Rect2(48, 16, 260, 38), 29, PAPER)
	_label(_canvas, _t("ORDER COUNTER", "点单区"), Rect2(48, 58, 260, 26), 17, PAPER)
	_button(_canvas, _t("Orders", "点单台"), Rect2(320, 18, 200, 64), "station", func(): _notice_text(_t("You are at the order station.", "你正在点单台。")), true)
	_button(_canvas, _t("Roast", "烤炉台"), Rect2(536, 18, 200, 64), "roast_stub", _other_station)
	_button(_canvas, _t("Prepare", "料理台"), Rect2(752, 18, 200, 64), "prep_stub", _other_station)
	_button(_canvas, _t("EN / 中文", "中文 / EN"), Rect2(968, 18, 132, 64), "language", _toggle_language)
	_button(_canvas, _t("Pause", "暂停"), Rect2(1116, 18, 116, 64), "pause", _toggle_pause)
	_button(_canvas, _t("Restart", "重来"), Rect2(1248, 18, 108, 64), "restart", _confirm_reset)
	if embedded:
		_button(_canvas, "×", Rect2(1370, 22, 52, 56), "close", func(): close_requested.emit())
	else:
		_label(_canvas, "01", Rect2(1370, 28, 60, 40), 24, PAPER)
	_panel(_canvas, Rect2(48, 124, 404, 512), Color("e6d7ba"), 16)
	_label(_canvas, _t("THE ORDER RAIL", "订单栏"), Rect2(82, 155, 226, 30), 21)
	_count_label = _label(_canvas, "", Rect2(330, 157, 95, 26), 16, MUTED)
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_queue = Control.new()
	_queue.position = Vector2(72, 190)
	_queue.size = Vector2(356, 362)
	_canvas.add_child(_queue)
	_button(_canvas, _t("+ Next guest", "+ 下一位顾客"), Rect2(72, 562, 224, 50), "next_guest", _next_guest, true)
	_button(_canvas, "AUTO", Rect2(312, 562, 116, 50), "auto", _toggle_auto)
	_content = Control.new()
	_content.position = Vector2(480, 124)
	_content.size = Vector2(912, 512)
	_canvas.add_child(_content)
	var hints := [
		[_t("01  Read the ticket", "01  看清订单"), _t("Select a guest on the rail.\nAmounts and exclusions stay on the ticket.", "点击左侧顾客。\n核对配料数量和特殊要求。")],
		[_t("02  Accept the order", "02  确认接单"), _t("Take up to three orders.\nThe ticket is recorded for the oven.", "同时最多接三张订单。\n记录订单，供烤炉模块接入。")],
		[_t("03  Keep an eye on time", "03  留意等待时间"), _t("The timer begins when a guest arrives.\nPause safely with Esc or the button.", "顾客到店后开始等待。\n按 Esc 或暂停按钮可暂停。")],
	]
	for index in range(hints.size()):
		var x := 48 + index * 456
		_panel(_canvas, Rect2(x, 692, 432, 160), Color("f4e8d1"), 12)
		_label(_canvas, hints[index][0], Rect2(x + 32, 724, 368, 36), 24)
		_label(_canvas, hints[index][1], Rect2(x + 32, 770, 368, 66), 17, MUTED)
	_message_label = _label(_canvas, _notice, Rect2(48, 862, 1344, 30), 17, PAPER)
	_fit()


func _refresh() -> void:
	if not is_instance_valid(_queue):
		return
	_clear(_queue)
	_clear(_content)
	_time_labels.clear()
	_bars.clear()
	_detail_time = null
	_detail_bar = null
	_accept_button = null
	for key in _buttons.keys():
		if str(key).begins_with("order_") or key == "accept":
			_buttons.erase(key)
	var orders: Array = manager.get_visible_orders()
	_count_label.text = "%d / %d" % [manager.get_active_count(), Manager.MAX_ACTIVE_ORDERS]
	for index in range(orders.size()):
		var order: Dictionary = orders[index]
		var id: String = order["order_id"]
		var y := index * 90.0
		var selected: bool = manager.selected_order_id == id
		var b := _button(_queue, "", Rect2(0, y, 356, 80), "order_" + id, func(): manager.select_order(id), selected)
		b.tooltip_text = _localized(order["special_request"])
		_label(b, id + "  ·  " + _localized(order["customer_name"]), Rect2(20, 12, 310, 27), 19, INK if selected else PAPER)
		_label(b, _status(order["status"]), Rect2(20, 38, 226, 26), 14, MUTED if selected else Color("e8c28b"))
		_time_labels[id] = _label(b, "", Rect2(253, 38, 90, 26), 16, RED if selected else PAPER)
		_bars[id] = _progress(b, Rect2(16, 65, 324, 5))
	var current: Dictionary = manager.get_order(manager.selected_order_id)
	if not manager.catalog_error.is_empty():
		_label(_content, _t("Recipe data could not load", "订单数据加载失败"), Rect2(28, 70, 800, 50), 32, RED)
		_label(_content, manager.catalog_error, Rect2(28, 140, 800, 130), 20)
	elif current.is_empty():
		_panel(_content, Rect2(0, 0, 912, 512), PAPER, 16)
		_label(_content, _t("A quiet moment at the counter.", "柜台前，稍作歇息。"), Rect2(48, 150, 810, 60), 32)
		_label(_content, _t("Invite the next guest to take an order.", "点击「下一位顾客」，开始接待。"), Rect2(48, 220, 810, 60), 22, MUTED)
	else:
		_draw_ticket(current)
	_refresh_times()
	var next: Button = _buttons["next_guest"]
	next.disabled = paused or not manager.catalog_error.is_empty()
	var pause_button: Button = _buttons["pause"]
	pause_button.text = _t("Resume", "继续") if paused else _t("Pause", "暂停")
	_buttons["auto"].text = "AUTO: ON" if _auto_arrivals else "AUTO: OFF"
	_message_label.text = _notice


func _draw_ticket(order: Dictionary) -> void:
	_panel(_content, Rect2(0, 0, 600, 512), PAPER, 16)
	_label(_content, _t("KITCHEN TICKET", "厨房订单"), Rect2(40, 30, 340, 28), 15, MUTED)
	_label(_content, order["order_id"], Rect2(430, 27, 130, 32), 23, RED)
	_label(_content, _localized(order["recipe_name"]), Rect2(40, 76, 520, 44), 31)
	_label(_content, _localized(order["special_request"]), Rect2(40, 125, 520, 40), 18, MUTED)
	for index in range(order["ingredients"].size()):
		var item: Dictionary = order["ingredients"][index]
		var ingredient: Dictionary = manager.catalog["ingredients"][item["id"]]
		var x := 28 + (index % 3) * 183
		var y := 172 + (index / 3) * 93
		_panel(_content, Rect2(x, y, 168, 82), Color("f0e5ce"), 9)
		var icon := AtlasTexture.new()
		icon.atlas = _atlas
		var icon_index: int = ICON_INDEX.get(ingredient["icon"], 0)
		var tile := Vector2(_atlas.get_width() / 4.0, _atlas.get_height() / 2.0)
		icon.region = Rect2(Vector2((icon_index % 4) * tile.x, (icon_index / 4) * tile.y) + Vector2(12, 12), tile - Vector2(24, 24))
		_picture(_content, icon, Rect2(x + 8, y + 4, 58, 58))
		_label(_content, "×%d" % int(item["quantity"]), Rect2(x + 113, y + 10, 46, 28), 22)
		var caption := _label(_content, ingredient[language], Rect2(x + 10, y + 56, 148, 23), 14)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var exclusions: Array = []
	for ingredient_id in order["excluded_ingredients"]:
		exclusions.append(manager.catalog["ingredients"][ingredient_id][language])
	var special := _t("No exclusions", "无忌口要求") if exclusions.is_empty() else _t("DO NOT ADD: ", "请勿添加：") + ", ".join(exclusions)
	_label(_content, special, Rect2(28, 365, 546, 28), 17, RED if not exclusions.is_empty() else MUTED)
	_detail_time = _label(_content, "", Rect2(28, 405, 300, 30), 20, GREEN)
	_detail_bar = _progress(_content, Rect2(28, 447, 265, 8))
	_accept_button = _button(_content, _t("Accept order  →", "确认接单  →"), Rect2(320, 411, 252, 66), "accept", _accept_current, true)
	if order["status"] != "pending":
		_accept_button.text = _t("Order accepted  ✓", "已接单  ✓")
		_accept_button.disabled = true
	elif manager.get_active_count() >= Manager.MAX_ACTIVE_ORDERS:
		_accept_button.text = _t("Kitchen is full", "厨房订单已满")
		_accept_button.disabled = true
	else:
		_accept_button.disabled = paused
	var customer_heading := _label(_content, _t("AT YOUR COUNTER", "到店顾客"), Rect2(648, 20, 240, 30), 18, PAPER)
	customer_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_picture(_content, _textures.get(order["portrait"]), Rect2(604, 60, 324, 365))
	var nameplate := _panel(_content, Rect2(624, 403, 288, 103), PAPER, 10)
	var name_label := _label(nameplate, _localized(order["customer_name"]), Rect2(28, 19, 232, 32), 25)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var status_label := _label(nameplate, _status(order["status"]), Rect2(28, 56, 232, 28), 16, RED)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _refresh_times() -> void:
	if manager == null:
		return
	for order in manager.get_visible_orders():
		var id: String = order["order_id"]
		var seconds: float = order["remaining_seconds"]
		var ratio := 100.0 * seconds / float(order["patience_seconds"])
		if _time_labels.has(id):
			_time_labels[id].text = "%ds" % ceili(seconds)
			_bars[id].value = ratio
		if id == manager.selected_order_id and is_instance_valid(_detail_time):
			_detail_time.text = _t("Waiting · %ds left", "等待中 · 剩余 %d 秒") % ceili(seconds)
			_detail_time.add_theme_color_override("font_color", RED if ratio < 25 else GREEN)
			_detail_bar.value = ratio


func _accept_current() -> void:
	if paused:
		return
	var id: String = manager.selected_order_id
	if not manager.accept_order(id):
		_notice_text(_t("Cannot accept: check the ticket and kitchen capacity.", "无法接单：请检查订单状态和厨房容量。"))


func _next_guest() -> void:
	if paused:
		return
	if manager.create_order().is_empty():
		_notice_text(_t("Read and accept the waiting guest first. Up to three accepted orders can be active.", "先接待当前等待的顾客；厨房最多同时处理三张已接订单。"))
	else:
		_notice_text(_t("A guest has arrived. Read their request before accepting.", "新顾客到店。先看清要求，再确认接单。"))


func _toggle_language() -> void:
	language = "zh" if language == "en" else "en"
	_notice = ""
	_build()
	_refresh()


func _other_station() -> void:
	_notice_text(_t("This is NEKO's order module. Other stations are not connected in this preview.", "这是 NEKO 的点单模块预览，烤炉与料理台尚未接入。"))


func _toggle_pause() -> void:
	paused = not paused
	pause_requested.emit(paused)
	_notice = _t("Paused. Orders and waiting times are preserved.", "已暂停，订单与等待时间保留。") if paused else _t("Back at the counter.", "继续接待。")
	_refresh()


func _toggle_auto() -> void:
	_auto_arrivals = not _auto_arrivals
	_auto_elapsed = 0.0
	_notice_text(_t("Automatic guests every 18 seconds; a waiting guest is never overwritten.", "自动模式每 18 秒尝试到店，不覆盖等待中的顾客。") if _auto_arrivals else _t("Manual arrivals. Use Next guest when ready.", "手动到店模式，准备好后点击下一位。"))
	_refresh()


func _confirm_reset() -> void:
	if not _owns_manager:
		restart_requested.emit()
		_notice_text(_t("The host game handles restarting shared orders.", "共享订单由主游戏统筹重新开始。"))
		return
	var was_paused := paused
	paused = true
	_refresh()
	var dialog := ConfirmationDialog.new()
	dialog.title = _t("Restart this counter?", "重新开始点单？")
	dialog.dialog_text = _t("This clears the demo orders. Other stations are not connected yet.", "将清空本演示的订单。目前尚未接入其他工作站。")
	dialog.confirmed.connect(func():
		manager.reset_orders()
		paused = was_paused
		manager.create_order()
		_notice_text(_t("A fresh start.", "重新开始接待。"))
		dialog.queue_free())
	dialog.canceled.connect(func():
		paused = was_paused
		_refresh()
		dialog.queue_free())
	add_child(dialog)
	dialog.popup_centered(Vector2i(470, 180))


func _on_order_changed(_order: Dictionary) -> void:
	_refresh()


func _on_selected(id: String) -> void:
	_refresh()
	order_selected.emit(id)


func _on_accepted(order: Dictionary) -> void:
	_notice_text(_t("%s accepted. Ticket recorded; oven integration is next.", "%s 已接单。订单已记录，等待烤炉模块接入。") % order["order_id"])
	order_accepted.emit(order.duplicate(true))


func _on_expired(id: String) -> void:
	_notice_text(_t("%s: the guest left. Their kitchen slot has been released.", "%s：顾客离开，厨房订单位置已释放。") % id)
	_refresh()


func _on_focus_entered() -> void:
	_focused = true


func _on_focus_exited() -> void:
	_focused = false


func _notice_text(message: String) -> void:
	_notice = message
	if is_instance_valid(_message_label):
		_message_label.text = message


func _t(en: String, zh: String) -> String:
	return zh if language == "zh" else en


func _localized(values: Dictionary) -> String:
	return values.get(language, values.get("en", ""))


func _status(value: String) -> String:
	var names: Array = STATUS_NAMES.get(value, [value, value])
	return names[1] if language == "zh" else names[0]


func _clear(node: Control) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _style(color: Color, radius: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	return style


func _painted_style(tile_index: int) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = _panel_tiles[tile_index]
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 16)
		style.set_content_margin(side, 0)
	return style


func _panel(parent: Control, rect: Rect2, color: Color, radius: int) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if rect.size.x <= 180 and rect.size.y <= 90:
		panel.add_theme_stylebox_override("panel", _style(Color(0.72, 0.46, 0.19, 0.09), 6))
	elif radius > 0:
		panel.add_theme_stylebox_override("panel", _painted_style(0 if color == PAPER else 3))
	else:
		panel.add_theme_stylebox_override("panel", _style(color, radius))
	parent.add_child(panel)
	return panel


func _label(parent: Control, text: String, rect: Rect2, font_size: int, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", _heading_font if font_size >= 21 else _font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.position = rect.position
	label.size = rect.size
	label.set_meta("layout_rect", rect)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _button(parent: Control, text: String, rect: Rect2, id: String, callback: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.name = id.replace("-", "_").to_pascal_case()
	button.position = rect.position
	button.size = rect.size
	button.text = text
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", _font)
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", INK if primary else PAPER)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_disabled_color", Color("827362"))
	button.add_theme_stylebox_override("normal", _painted_style(2 if primary else 1))
	button.add_theme_stylebox_override("hover", _painted_style(2))
	button.add_theme_stylebox_override("pressed", _painted_style(0))
	button.add_theme_stylebox_override("disabled", _painted_style(3))
	var focus := _style(Color(0, 0, 0, 0))
	focus.border_color = GOLD
	focus.set_border_width_all(3)
	button.add_theme_stylebox_override("focus", focus)
	button.pressed.connect(callback)
	parent.add_child(button)
	_buttons[id] = button
	return button


func _progress(parent: Control, rect: Rect2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.add_theme_font_size_override("font_size", 1)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background", _style(Color("cabb9e"), 4))
	bar.add_theme_stylebox_override("fill", _style(GOLD, 4))
	bar.position = rect.position
	bar.size = rect.size
	parent.add_child(bar)
	return bar


func _picture(parent: Control, texture: Texture2D, rect: Rect2, preserve_aspect: bool = true) -> void:
	var picture := TextureRect.new()
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.texture = texture
	picture.position = rect.position
	picture.size = rect.size
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if preserve_aspect else TextureRect.STRETCH_SCALE
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(picture)
