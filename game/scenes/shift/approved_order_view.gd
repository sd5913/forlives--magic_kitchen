extends Control
## Runtime binding of the approved Figma counter, node 217:1122. No alternate artwork.
const CANVAS_SIZE := Vector2(1536, 1024)
const INK := Color("321c0d")
const MUTED := Color("765131")
const INVERSE := Color("fff1cb")
const SOURCE := "res://assets/ui/order_counter/source/"
var host: Control
var session: Node
var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/approved_order_layout.json"))
var source_texture: Texture2D
var font: Font
var buttons: Dictionary = {}
var time_labels: Dictionary = {}
var _main_clock: Label
var _overlay: Control
var _overlay_mode := ""
var _overlay_clocks: Dictionary = {}


func initialize(owner_host: Control) -> void:
	host = owner_host
	session = host.session
	size = CANVAS_SIZE
	source_texture = load(SOURCE + "shared_source.png")
	font = load("res://assets/fonts/bree_serif_regular.ttf") if host.language == "en" else host._font
	build()


func build() -> void:
	_picture(self, load(SOURCE + "order_counter_background.png"), Rect2(Vector2.ZERO, CANVAS_SIZE))
	_header()
	_hanger()
	_ticket()
	_queue()
	_customer_request()
	_service_bar()
	refresh_times()
	if session.paused:
		show_overlay("pause")


func _header() -> void:
	_skin(self, "brand", Rect2(2, 0, 326, 114), 24)
	_label(self, _t("Peking Duck Rolls", "北京烤鸭卷"), Rect2(40, 18, 245, 36), 28)
	_label(self, _t("Order Station", "点单区"), Rect2(49, 53, 246, 36), 28)
	var seal := ColorRect.new()
	seal.position = Vector2(273, 18)
	seal.size = Vector2(32, 64)
	seal.color = Color("9f2816")
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(seal)
	var stamp := _label(self, "Old\nBeijing\nFlavor", Rect2(274, 24, 30, 46), 8, INVERSE)
	stamp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for entry in [["order", "Order Station", "点单区", 362], ["roast", "Roasting Station", "烘烤区", 634], ["prepare", "Cooking Station", "料理台", 910]]:
		var destination: String = entry[0]
		_button(self, _t(entry[1], entry[2]), Rect2(entry[3], 8, 248, 72), "nav_" + destination, func(): host._navigate(destination), false, destination == "order")
	var pause := _button(self, "", Rect2(1452, 14, 64, 64), "pause", host._pause, false, false, true)
	_picture(pause, load(SOURCE + "pause.svg"), Rect2(18, 18, 28, 28))
	pause.tooltip_text = _t("Pause (Esc)", "暂停（Esc）")


func _hanger() -> void:
	for i in range(7):
		_sample(self, layout.decorations.rope, Rect2(26 + 958 * (0.0459 + i * 0.1297), 117, 958 * 0.1298, 22))
	_sample(self, layout.decorations.anchor_left, Rect2(26, 106, 40, 42))
	_sample(self, layout.decorations.anchor_right, Rect2(944, 106, 40, 42))


func _ticket() -> void:
	var order: Dictionary = session.manager.get_order(session.manager.selected_order_id)
	_skin(self, "main_ticket", Rect2(32, 144, 320, 548), 24)
	_clip(Vector2(180, 132))
	if order.is_empty():
		_label(self, _t("No waiting orders", "暂无等待订单"), Rect2(62, 244, 258, 60), 24)
		return
	var title := _label(self, _order_name(order.order_id), Rect2(32, 164, 320, 42), 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label(self, _t("Peking Duck Wrap ×1", "北京烤鸭卷 ×1"), Rect2(62, 244, 258, 28), 20)
	_label(self, _recipe_name(order.recipe_id), Rect2(62, 284, 258, 22), 16, MUTED)
	_sample(self, layout.decorations.divider, Rect2(62, 318, 250, 6))
	var items := _recipe_items(order)
	var gap := 56 if items.size() <= 4 else 44
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var y := 336 + index * gap
		_picture(self, _food_texture(item.id), Rect2(62, y + 6, 32, 32))
		_label(self, _ingredient_name(item.id), Rect2(106, y + 8, 164, 28), 20)
		_label(self, "×%d" % int(item.quantity), Rect2(282, y + 8, 34, 28), 20)
	var status_y := 336 + items.size() * gap
	_label(self, _ticket_status(order.status), Rect2(62, status_y, 258, 22), 16, MUTED)
	_main_clock = _label(self, "", Rect2(62, status_y + 34, 258, 28), 20)
	var expand := _button(self, "", Rect2(62, status_y + 74, 64, 64), "expand", func(): show_overlay("detail"), not session.can_interact(), false, true)
	_picture(expand, load(SOURCE + "expand.svg"), Rect2(18, 18, 28, 28))
	expand.tooltip_text = _t("Expand order", "展开订单")


func _queue() -> void:
	var index := 0
	for order in session.manager.get_visible_orders():
		if order.order_id == session.manager.selected_order_id:
			continue
		var id: String = order.order_id
		var x := 376 + index * 192
		var button := _plain_button(self, Rect2(x, 144, 176, 180), "ticket_" + id, func(): host._select(id), not session.can_interact())
		_skin(button, "mini_ticket", Rect2(0, 0, 176, 180), 14)
		_clip(Vector2(x + 78, 132))
		var title := _label(button, _order_name(id), Rect2(0, 20, 176, 36), 28)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label(button, _compact_status(order.status), Rect2(24, 70, 132, 22), 16, MUTED)
		time_labels[id] = _label(button, "", Rect2(24, 102, 132, 28), 20)
		_label(button, _t("Click to inspect", "点击查看"), Rect2(24, 140, 132, 22), 16, MUTED)
		index += 1


func _customer_request() -> void:
	_skin(self, "parchment", Rect2(1120, 360, 384, 218), 24)
	var order: Dictionary = session.manager.get_order(session.manager.selected_order_id)
	var request_title := _t("One duck wrap, please!", "请给我一份烤鸭卷！")
	var request_body := _request_text(order)
	_label(self, request_title, Rect2(1148, 386, 328, 72), 28)
	_label(self, request_body, Rect2(1148, 434, 328, 114), 20)
	var pending: bool = order.get("status") == "pending"
	_label(self, _t("Check the ticket before accepting", "接单前请先核对小票") if pending else _t("Your order stays with you.", "切换工作区，订单仍会保留。"), Rect2(1192, 650, 300, 22), 16, INVERSE)
	var ready: bool = order.get("status") == "ready_to_serve"
	var caption := _t("Confirm Order", "确认接单") if pending else (_t("Ready to serve", "交付订单") if ready else _t("Order accepted", "已接单"))
	_button(self, caption, Rect2(1192, 682, 248, 72), "accept", _primary_action, not session.can_interact() or (not pending and not ready))


func _service_bar() -> void:
	_sample(self, [600, 734, 360, 42], Rect2(32, 776, 1472, 48))
	_picture(self, load(SOURCE + "hand_open.svg"), Rect2(52, 782, 32, 32))
	_label(self, _t("Input Status: Mouse controls active · Click an order ticket to inspect", "输入状态：鼠标操作 · 点击小票查看订单"), Rect2(96, 782, 1400, 32), 20, INVERSE)
	_skin(self, "parchment", Rect2(32, 840, 1472, 152), 24)
	_picture(self, load(SOURCE + "order.svg"), Rect2(64, 892, 32, 32))
	var waiting := 0
	for order in session.manager.get_visible_orders():
		if order.status == "pending":
			waiting += 1
	_label(self, _t("%d active · %d waiting", "%d 单制作中 · %d 单待接") % [session.manager.get_active_count(), waiting], Rect2(124, 880, 1040, 40), 28)
	_label(self, _t("Switch stations freely. Your orders stay with you.", "自由切换工作区，订单和制作进度都会保留。"), Rect2(124, 928, 1040, 32), 20, MUTED)
	_button(self, _t("View all orders", "查看全部订单"), Rect2(1224, 880, 248, 72), "all_orders", func(): show_overlay("all"), not session.can_interact())


func _primary_action() -> void:
	var order: Dictionary = session.manager.get_order(session.manager.selected_order_id)
	if order.get("status") == "pending":
		session.accept_current()
	elif order.get("status") == "ready_to_serve":
		session.serve_current()


func refresh_times() -> void:
	var current: Dictionary = session.manager.get_order(session.manager.selected_order_id)
	if is_instance_valid(_main_clock) and not current.is_empty():
		_main_clock.text = _t("Patience ", "耐心剩余 ") + _time(float(current.remaining_seconds))
	for id in time_labels:
		var order: Dictionary = session.manager.get_order(id)
		if not order.is_empty():
			time_labels[id].text = _time(float(order.remaining_seconds))
	for id in _overlay_clocks:
		var order: Dictionary = session.manager.get_order(id)
		if not order.is_empty():
			_overlay_clocks[id].text = _time(float(order.remaining_seconds))


func show_overlay(mode: String) -> void:
	close_overlay()
	_overlay_mode = mode
	_overlay = Control.new()
	_overlay.size = CANVAS_SIZE
	add_child(_overlay)
	var scrim := ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.48)
	scrim.size = CANVAS_SIZE
	_overlay.add_child(scrim)
	var dimensions := Vector2(760, 820) if mode == "detail" else (Vector2(1100, 640) if mode == "all" else Vector2(660, 460))
	var panel := Control.new()
	panel.position = (CANVAS_SIZE - dimensions) / 2.0
	panel.size = dimensions
	_overlay.add_child(panel)
	_skin(panel, "parchment", Rect2(Vector2.ZERO, dimensions), 24)
	if mode == "detail":
		_detail_contents(panel)
	elif mode == "all":
		_all_contents(panel)
	else:
		_pause_contents(panel)
	host.receiver.invalidate()
	refresh_times()


func close_overlay() -> void:
	if is_instance_valid(_overlay):
		remove_child(_overlay)
		_overlay.queue_free()
	_overlay = null
	_overlay_clocks.clear()
	_overlay_mode = ""
	if is_instance_valid(host):
		host.receiver.invalidate()


func overlay_open() -> bool:
	return is_instance_valid(_overlay)


func _detail_contents(panel: Control) -> void:
	var order: Dictionary = session.manager.get_order(session.manager.selected_order_id)
	if order.is_empty():
		_label(panel, _t("This order has expired.", "这张订单已过期。"), Rect2(56, 48, 648, 60), 28)
		_button(panel, _t("Back to counter", "返回柜台"), Rect2(56, 150, 248, 72), "collapse_empty", close_overlay)
		return
	_label(panel, _order_name(order.order_id), Rect2(56, 48, 648, 44), 36)
	_label(panel, _t("Peking Duck Wrap ×1", "北京烤鸭卷 ×1"), Rect2(56, 116, 648, 36), 28)
	_label(panel, _recipe_name(order.recipe_id) + " · " + _compact_status(order.status), Rect2(56, 176, 648, 28), 20, MUTED)
	_sample(panel, layout.decorations.divider, Rect2(56, 228, 648, 6))
	var items := _recipe_items(order)
	for i in range(items.size()):
		_label(panel, _ingredient_name(items[i].id), Rect2(56, 258 + i * 60, 580, 36), 28)
		_label(panel, "×%d" % int(items[i].quantity), Rect2(676, 258 + i * 60, 40, 36), 28)
	var clock_y := 258 + items.size() * 60
	_label(panel, _t("Patience", "耐心剩余"), Rect2(56, clock_y, 148, 36), 28)
	_overlay_clocks[order.order_id] = _label(panel, "", Rect2(210, clock_y, 150, 36), 28)
	var collapse := _button(panel, "", Rect2(56, clock_y + 60, 64, 64), "collapse", close_overlay, false, false, true)
	_picture(collapse, load("res://assets/ui/order_counter/collapse.svg"), Rect2(18, 18, 28, 28))
	_button(panel, _t("Confirm Order", "确认接单") if order.status == "pending" else _t("Order accepted", "已接单"), Rect2(144, clock_y + 60, 248, 72), "detail_accept", func(): close_overlay(); _primary_action(), order.status != "pending" or not session.can_interact())


func _all_contents(panel: Control) -> void:
	_label(panel, _t("All orders", "全部订单"), Rect2(48, 40, 1004, 44), 36)
	_label(panel, _t("Select a ticket to inspect its recipe.", "选择小票，查看配方与制作状态。"), Rect2(48, 112, 1004, 28), 20, MUTED)
	var orders: Array = session.manager.get_visible_orders()
	for i in range(orders.size()):
		var order: Dictionary = orders[i]
		var id: String = order.order_id
		var row := _plain_button(panel, Rect2(48, 168 + i * 96, 1004, 68), "list_" + id, func(): close_overlay(); host._select(id))
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color("f5d8a3")
		row.add_theme_stylebox_override("normal", fill)
		_label(row, "%02d   %s" % [int(id.get_slice("-", 1)), _recipe_name(order.recipe_id)], Rect2(20, 16, 540, 36), 28)
		_label(row, _compact_status(order.status), Rect2(570, 16, 260, 36), 28)
		_overlay_clocks[id] = _label(row, "", Rect2(850, 16, 140, 36), 28)
	_button(panel, _t("Back to counter", "返回柜台"), Rect2(48, 168 + maxi(3, orders.size()) * 96, 248, 72), "back_counter", close_overlay)


func _pause_contents(panel: Control) -> void:
	var heading := _label(panel, _t("Kitchen paused", "小店已暂停"), Rect2(80, 64, 500, 44), 36)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var body := _label(panel, _t("Orders and timers are paused.", "订单和计时均已暂停。"), Rect2(80, 136, 500, 28), 20, MUTED)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(panel, _t("Resume", "继续"), Rect2(206, 192, 248, 72), "resume", host._pause)
	_button(panel, _t("Back to start", "重新开始"), Rect2(206, 292, 248, 72), "back_start", host._confirm_restart)


func _skin(parent: Control, skin: String, rect: Rect2, border: float) -> void:
	var xs := [0.0, border, rect.size.x - border]
	var ys := [0.0, border, rect.size.y - border]
	var widths := [border, rect.size.x - 2 * border, border]
	var heights := [border, rect.size.y - 2 * border, border]
	var regions: Array = layout.skins[skin]
	for i in range(9):
		var col := i % 3
		var row := i / 3
		_sample(parent, regions[i], Rect2(rect.position + Vector2(xs[col], ys[row]), Vector2(widths[col], heights[row])))


func _clip(position: Vector2) -> void:
	_sample(self, layout.decorations.clip, Rect2(position, Vector2(20, 32)))
	var slit := ColorRect.new()
	slit.position = position + Vector2(8, 5)
	slit.size = Vector2(4, 18)
	slit.color = Color("2d1309")
	slit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(slit)


func _sample(parent: Control, region: Array, target: Rect2) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = source_texture
	texture.region = Rect2(region[0], region[1], region[2], region[3])
	_picture(parent, texture, target)


func _picture(parent: Control, texture: Texture2D, rect: Rect2) -> void:
	var picture := TextureRect.new()
	picture.position = rect.position
	picture.size = rect.size
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_SCALE
	picture.texture = texture
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(picture)


func _plain_button(parent: Control, rect: Rect2, id: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.disabled = disabled
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	button.pressed.connect(callback)
	parent.add_child(button)
	buttons[id] = button
	return button


func _button(parent: Control, text: String, rect: Rect2, id: String, callback: Callable, disabled: bool = false, selected: bool = false, icon: bool = false) -> Button:
	var button := _plain_button(parent, rect, id, callback, disabled)
	_skin(button, "icon" if icon else ("navigation_red" if selected else "navigation_paper"), Rect2(Vector2.ZERO, rect.size), 14 if icon else 18)
	if not text.is_empty():
		var caption := _label(button, text, Rect2(8, (rect.size.y - 32) / 2, rect.size.x - 16, 32), 24, INVERSE if selected else INK)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return button


func _label(parent: Control, text: String, rect: Rect2, font_size: int, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size = rect.size
	label.clip_text = false
	label.set_meta("design_rect", rect)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	# Theme/font minima settle after entering the tree; restore the Figma width then.
	label.set_deferred("size", rect.size)
	return label


func _food_texture(id: String) -> Texture2D:
	var tiles := {"duck_meat": Vector2(1, 0), "cucumber": Vector2(2, 0), "scallion": Vector2(0, 1), "hawthorn": Vector2(1, 1), "sweet_sauce": Vector2(2, 1)}
	var texture := AtlasTexture.new()
	texture.atlas = load(SOURCE + "food_source.png")
	texture.region = Rect2(tiles[id] * 512, Vector2(512, 512))
	return texture


func _recipe_items(order: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for ingredient in ["duck_meat", "cucumber", "scallion", "hawthorn", "sweet_sauce"]:
		for item in order.ingredients:
			if item.id == ingredient:
				result.append(item)
	return result


func _ingredient_name(id: String) -> String:
	var names := {"duck_meat": "Sliced duck", "cucumber": "Cucumber", "scallion": "Scallions", "hawthorn": "Hawthorn strips", "sweet_sauce": "Sweet bean sauce"}
	return session.manager.catalog.ingredients[id].zh if host.language == "zh" else names.get(id, id)


func _recipe_name(id: String) -> String:
	var names := {"classic": ["Classic recipe", "经典配方"], "no_scallion": ["No scallion", "不要葱"], "hawthorn": ["With hawthorn", "山楂配方"]}
	return names.get(id, [id, id])[1 if host.language == "zh" else 0]


func _request_text(order: Dictionary) -> String:
	if order.is_empty():
		return _t("The next guest is on the way.", "下一位顾客正在路上。")
	if order.recipe_id == "classic":
		return _t("Duck, cucumber, scallions and sweet bean sauce.", "鸭肉、黄瓜、葱和甜面酱。")
	return order.special_request[host.language]


func _ticket_status(status: String) -> String:
	return _t("WAITING · Ready to take", "待接单 · 可以接单") if status == "pending" else _compact_status(status)


func _compact_status(status: String) -> String:
	var names := {"pending": ["Waiting", "待接单"], "accepted": ["Accepted", "已接单"], "roasting": ["Roasting", "烘烤中"], "preparing": ["Preparing", "料理中"], "ready_to_serve": ["Ready", "待交付"], "served": ["Served", "已交付"], "expired": ["Expired", "已过期"]}
	return names.get(status, [status, status])[1 if host.language == "zh" else 0]


func _order_name(id: String) -> String:
	return _t("Order %02d", "订单 %02d") % int(id.get_slice("-", 1))


func _time(seconds: float) -> String:
	var whole := ceili(seconds)
	return "%02d:%02d" % [whole / 60, whole % 60]


func _t(en: String, zh: String) -> String:
	return zh if host.language == "zh" else en
