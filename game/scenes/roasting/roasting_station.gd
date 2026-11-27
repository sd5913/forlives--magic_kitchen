extends Control
## Approved roasting layers; all food, clock and input rules remain in ShiftSession.
const CANVAS_SIZE := Vector2(1536, 1024)
const SOURCE := "res://assets/roasting/"
const INK := Color("44270f")
const PAPER := Color("ffedc0")
var host: Control
var session: Node
var font: Font
var buttons: Dictionary = {}
var ducks: Dictionary = {}
var pointer: TextureRect
var progress: Label
var status_line: Label
var patience: Label
var texture_cache: Dictionary = {}


func initialize(owner_host: Control) -> void:
	host = owner_host
	session = host.session
	size = CANVAS_SIZE
	font = load("res://assets/fonts/bree_serif_regular.ttf") if host.language == "en" else host._font
	build()


func build() -> void:
	_picture(self, _texture("art/scene_empty.png"), Rect2(0, 0, 1536, 1024))
	_picture(self, _texture("ui/header.png"), Rect2(2, 0, 1514, 114))
	for item in [["order", 362], ["roast", 634], ["prepare", 910]]:
		var destination: String = item[0]
		buttons["nav_" + destination] = _hit(Rect2(item[1], 8, 248, 72), func(): host._navigate(destination), not session.can_interact())
	buttons.pause = _hit(Rect2(1452, 14, 64, 64), host._pause)
	if session.paused:
		_label(self, _t("Resume", "继续"), Rect2(1452, 80, 64, 24), 16, PAPER)
	_button(_t("EN / 中文", "EN / 中文"), Rect2(1192, 15, 140, 34), func(): host.language = "zh" if host.language == "en" else "en"; host._dirty = true)
	_button(_t("All tickets", "全部订单"), Rect2(1192, 57, 140, 34), host._show_orders, not session.can_interact())
	_button(_t("Camera", "摄像头"), Rect2(1340, 57, 104, 34), host.receiver.toggle_camera)
	_picture(self, _texture("ui/order_rope.png"), Rect2(26, 106, 958, 42))
	_ticket()
	_queue()
	for item in [["to_roast", 542], ["cooling", 723]]:
		_picture(self, _texture("ui/tray_label_%s.png" % item[0]), Rect2(540, item[1], 206, 50))
	var entry: Dictionary = session.current_food()
	var stage: String = entry.get("stage", "waiting")
	var selected: String = session.manager.selected_order_id
	var selected_order: Dictionary = session.manager.get_order(selected)
	if stage == "waiting" and selected_order.get("status", "") not in ["expired", "served"]:
		_picture(self, _texture("art/sprites/duck_raw.png"), Rect2(470, 421, 382, 127))
	elif stage in ["taken_out", "slicing"]:
		var tray_duck := _picture(self, _texture("art/sprites/duck_on_cooling_tray.png"), Rect2(470, 602, 382, 127))
		if entry.get("quality") == "burnt":
			tray_duck.modulate = Color("695042")
		elif entry.get("quality") == "raw":
			tray_duck.modulate = Color("e3c6a3")
	elif stage in ["preparing", "wrapping", "ready"]:
		_picture(self, _texture("art/sprites/duck_sliced_platter.png"), Rect2(480, 593, 354, 118))
	var oven_ids: Array = []
	for id in session.food:
		if session.food[id].stage == "roasting":
			oven_ids.append(id)
	for i in range(oven_ids.size()):
		var id: String = oven_ids[i]
		ducks[id] = _picture(self, _texture("art/sprites/duck_undercooked.png"), Rect2(1095 + i * 170, 438, 155, 232))
		var select_duck := _hit(Rect2(1095 + i * 170, 438, 155, 232), func(): host._select(id), not session.can_interact())
		select_duck.tooltip_text = _t("Select this duck's ticket", "选择这只鸭对应的订单")
	_picture(self, _texture("ui/doneness_track.png"), Rect2(946, 716, 556, 48))
	pointer = _picture(self, _texture("ui/doneness_pointer.png"), Rect2(946, 701, 20, 15))
	progress = _label(self, "", Rect2(40, 691, 330, 30), 18, PAPER)
	status_line = _label(self, "", Rect2(40, 760, 450, 35), 16, PAPER)
	_actions()
	_button(_t("Go to Cooking", "前往料理台"), Rect2(1160, 780, 340, 36), func(): host._navigate("prepare"), not session.can_interact())
	_label(self, session.message if not session.paused else _t("Paused — click the pause icon to resume", "已暂停，点击右上角继续"), Rect2(40, 988, 1450, 30), 18, PAPER)
	refresh_times()


func _ticket() -> void:
	_picture(self, _texture("ui/order_ticket_main_skin.png"), Rect2(32, 144, 320, 548))
	_clip(Vector2(180, 132))
	var order: Dictionary = session.manager.get_order(session.manager.selected_order_id)
	if order.is_empty():
		_label(self, _t("No active ticket", "暂无订单"), Rect2(54, 180, 280, 45), 26)
		return
	_label(self, _order_name(order.order_id), Rect2(57, 168, 280, 42), 30)
	_picture(self, host._textures.wrap, Rect2(50, 224, 80, 80))
	_label(self, _t("Peking Duck\nWrap × 1", "北京烤鸭卷 × 1"), Rect2(137, 229, 200, 67), 24)
	var items: Array = order.ingredients.filter(func(item): return item.id != "wrapper")
	for i in range(items.size()):
		var ingredient: String = items[i].id
		var y := 320 + i * 53
		_picture(self, host._textures[ingredient], Rect2(52, y, 66, 48))
		var label_text: String = session.manager.catalog.ingredients[ingredient][host.language]
		_label(self, label_text, Rect2(126, y + 3, 194, 44), 20)
	patience = _label(self, "", Rect2(58, 611, 276, 28), 18)
	buttons.details = _hit(Rect2(32, 144, 320, 548), host._show_details, not session.can_interact())


func _queue() -> void:
	var slot := 0
	for order in session.manager.get_visible_orders():
		if order.order_id == session.manager.selected_order_id:
			continue
		var x := 376 + slot * 192
		_picture(self, _texture("ui/order_ticket_small_skin.png"), Rect2(x, 144, 176, 180))
		_clip(Vector2(x + 77, 132))
		_label(self, _order_name(order.order_id), Rect2(x + 16, 167, 150, 30), 22)
		var row := 0
		for item in order.ingredients:
			if item.id in ["wrapper", "duck_meat"]:
				continue
			_picture(self, host._textures[item.id], Rect2(x + 14, 205 + row * 30, 32, 27))
			_label(self, session.manager.catalog.ingredients[item.id][host.language], Rect2(x + 49, 204 + row * 30, 115, 30), 14)
			row += 1
		var id: String = order.order_id
		buttons[id] = _hit(Rect2(x, 144, 176, 180), func(): host._select(id), not session.can_interact())
		slot += 1


func _actions() -> void:
	var entry: Dictionary = session.current_food()
	var stage: String = entry.get("stage", "waiting")
	var titles := [_t("1 · Load Duck", "1 · 放入烤鸭"), _t("2 · Remove Duck", "2 · 取出烤鸭"), _t("3 · Slice Duck", "3 · 片烤鸭")]
	for i in range(3):
		var x := 32 + i * 496
		var available: bool = session.action_available(i + 1)
		var completed: bool = (i == 0 and stage != "waiting") or (i == 1 and stage in ["taken_out", "slicing", "preparing", "wrapping", "ready"]) or (i == 2 and stage in ["preparing", "wrapping", "ready"])
		_picture(self, _texture("ui/gesture_card_base.png"), Rect2(x, 824, 480, 160))
		_picture(self, host._textures["hand_%d" % (i + 1)], Rect2(x + 32, 840, 112, 125))
		_label(self, titles[i], Rect2(x + 160, 857, 310, 40), 27)
		var caption := _t("Ready · Show %d", "可操作 · 比出 %d") % (i + 1) if available else (_t("Completed", "已完成") if completed else _t("Not available yet", "暂不可用"))
		_label(self, caption, Rect2(x + 160, 905, 310, 42), 21, Color("42672e") if available else INK)
		var number := i + 1
		buttons["action_%d" % number] = _hit(Rect2(x, 824, 480, 160), func(): session.perform_action(number), not available)


func refresh_times() -> void:
	var order: Dictionary = session.manager.get_order(session.manager.selected_order_id)
	var entry: Dictionary = session.current_food()
	if is_instance_valid(patience) and not order.is_empty():
		patience.text = _t("Patience: %ds", "耐心：%d 秒") % ceili(order.remaining_seconds)
	for id in ducks:
		var seconds: float = session.food[id].roast_seconds
		var quality: String = session.roast_quality(seconds)
		ducks[id].texture = _texture("art/sprites/duck_%s.png" % {"raw": "undercooked", "cooked": "ready", "burnt": "burnt"}[quality])
	var seconds: float = entry.get("roast_seconds", 0.0)
	# The approved track has equal thirds; map each rule boundary to its colour boundary.
	var cooked: float = session.rules.cooked_seconds
	var burnt: float = session.rules.burnt_seconds
	var fraction := seconds / cooked / 3.0 if seconds < cooked else (1.0 / 3.0 + (seconds - cooked) / (burnt - cooked) / 3.0 if seconds < burnt else 2.0 / 3.0 + minf((seconds - burnt) / (burnt - cooked), 1.0) / 3.0)
	pointer.position.x = 946 + clampf(fraction, 0.0, 1.0) * 536
	pointer.visible = entry.get("stage", "waiting") != "waiting"
	progress.text = _t("Progress: ", "进度：") + host._status(order.get("status", "pending"))
	status_line.text = host.receiver.status


func _texture(path: String) -> Texture2D:
	if not texture_cache.has(path):
		texture_cache[path] = load(SOURCE + path)
	return texture_cache[path]


func _clip(position: Vector2) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = _texture("ui/order_ticket_main_frame.png")
	atlas.region = Rect2(148, 0, 22, 36)
	_picture(self, atlas, Rect2(position, Vector2(22, 36)))


func _picture(parent: Control, texture: Texture2D, rect: Rect2) -> TextureRect:
	var node := TextureRect.new()
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.texture = texture
	node.position = rect.position
	node.size = rect.size
	node.stretch_mode = TextureRect.STRETCH_SCALE
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node


func _label(parent: Control, text: String, rect: Rect2, font_size: int, color: Color = INK) -> Label:
	var node := Label.new()
	node.text = text
	node.position = rect.position
	node.size = rect.size
	node.add_theme_font_override("font", font)
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node


func _hit(rect: Rect2, callback: Callable, disabled: bool = false) -> Button:
	var node := Button.new()
	node.position = rect.position
	node.size = rect.size
	node.disabled = disabled
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(1, 0.87, 0.5, 0.12) if state == "hover" else Color(0, 0, 0, 0)
		if state == "focus":
			style.set_border_width_all(2)
			style.border_color = Color("b77a31")
		node.add_theme_stylebox_override(state, style)
	node.pressed.connect(callback)
	add_child(node)
	return node


func _button(text: String, rect: Rect2, callback: Callable, disabled: bool = false) -> Button:
	_picture(self, _texture("ui/gesture_card_base.png"), rect)
	var node := _hit(rect, callback, disabled)
	_label(self, text, rect, 18).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return node


func _t(en: String, zh: String) -> String:
	return zh if host.language == "zh" else en


func _order_name(id: String) -> String:
	return _t("Order %02d", "订单 %02d") % int(id.get_slice("-", 1))
