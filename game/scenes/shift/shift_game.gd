extends Control
## Shared station shell; original contributor scenes remain independently editable.
const Session = preload("res://scenes/shift/shift_session.gd")
const ApprovedOrderView = preload("res://scenes/shift/approved_order_view.gd")
const Receiver = preload("res://scenes/shift/gesture_receiver.gd")
const DESIGN_SIZE := Vector2(1440, 900)
const INK := Color("542c14")
const PAPER := Color("ffedc0")
const GOLD := Color("df9b3e")
const FOOD_FILES := {"duck_meat": "sliced_duck", "hawthorn": "hawthorn_strips", "scallion": "scallions", "cucumber": "cucumber", "sweet_sauce": "sweet_bean_sauce"}
var session := Session.new()
var receiver := Receiver.new()
var language := "en"
var _canvas: Control
var _body: Control
var _order_view: Control
var _font := SystemFont.new()
var _textures: Dictionary = {}
var _dirty := true
var _refresh_elapsed := 0.0
var _popup: PanelContainer
var _popup_scrim: ColorRect
var _popup_clocks: Dictionary = {}
var _key_holds: Dictionary = {}
var _camera_line: Label
var _last_signature := ""
var _rail_clocks: Dictionary = {}
var _oven_clocks: Dictionary = {}
var _oven_bars: Dictionary = {}
var _ticket_clock: Label


func _ready() -> void:
	_font.font_names = PackedStringArray(["Arial Unicode MS", "Noto Sans CJK SC", "Microsoft YaHei", "Arial"])
	_font.allow_system_fallback = OS.get_name() != "macOS"
	_load_art()
	session.name = "ShiftSession"
	add_child(session)
	receiver.name = "GestureReceiver"
	add_child(receiver)
	receiver.gate.stable_seconds = float(session.rules.gesture_stable_seconds)
	receiver.gate.release_seconds = float(session.rules.gesture_release_seconds)
	receiver.gesture_triggered.connect(_receive_gesture)
	receiver.status_changed.connect(func(_status): _dirty = true)
	session.changed.connect(func(): _dirty = true)
	_canvas = Control.new()
	_canvas.size = DESIGN_SIZE
	add_child(_canvas)
	resized.connect(_fit)
	get_window().focus_exited.connect(_on_focus_lost)
	_fit()
	_refresh()


func _load_art() -> void:
	for key in ["kitchen_background", "navigation_paper_frame", "navigation_selected_frame", "parchment_panel", "order_main_frame", "order_mini_frame"]:
		_textures[key] = load("res://assets/ui/cooking_station/%s.png" % key)
	for key in FOOD_FILES:
		_textures[key] = load("res://assets/ui/food/%s.png" % FOOD_FILES[key])
	_textures["portraits"] = load("res://assets/ui/orders/customer_portraits.png")
	_textures["wrap"] = load("res://assets/ui/food/duck_wrap.png")
	for number in range(6):
		_textures["hand_%d" % number] = load("res://assets/ui/gestures/%s.png" % ("fist" if number == 0 else "number_%d" % number))


func _fit() -> void:
	if not is_instance_valid(_canvas):
		return
	var design_size := _canvas.size
	var factor := minf(size.x / design_size.x, size.y / design_size.y)
	_canvas.scale = Vector2.ONE * factor
	_canvas.position = (size - design_size * factor) / 2.0
	if is_instance_valid(_popup):
		_popup.scale = Vector2.ONE * factor
		_popup.position = (size - _popup.size * factor) / 2.0


func _process(delta: float) -> void:
	session.advance_time(delta)
	receiver.enabled = session.can_interact() and not _popup_open()
	_refresh_timers()
	if _dirty and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _view_signature() != _last_signature:
			_refresh()
		_dirty = false


func _popup_open() -> bool:
	return (is_instance_valid(_popup) and _popup.visible) or (is_instance_valid(_order_view) and _order_view.overlay_open())


func _receive_gesture(number: int) -> void:
	if not _popup_open():
		session.perform_action(number)


func _view_signature() -> String:
	var snapshot := {"station": session.station, "paused": session.paused, "summary": session.summary_visible, "rating": session.rating, "can_return": session.can_return(), "message": session.message, "selected": session.manager.selected_order_id, "language": language, "camera": receiver.status, "orders": [], "food": session.food.duplicate(true)}
	for order in session.manager.get_visible_orders():
		snapshot.orders.append([order.order_id, order.status])
	for entry in snapshot.food.values():
		entry.erase("roast_seconds")
		entry.erase("animation_seconds")
	return JSON.stringify(snapshot)


func _refresh_timers() -> void:
	if is_instance_valid(_order_view):
		_order_view.refresh_times()
	for id in _popup_clocks:
		var order := session.manager.get_order(id)
		if not order.is_empty():
			var button: Button = _popup_clocks[id]
			button.text = "%s · %s · %ds · %s" % [id, order.recipe_name[language], ceili(order.remaining_seconds), _status(order.status)]
			button.disabled = order.status in ["served", "expired"] or not session.can_interact()
	for id in _rail_clocks:
		var order := session.manager.get_order(id)
		if not order.is_empty() and is_instance_valid(_rail_clocks[id]):
			_rail_clocks[id].text = "%s · %ds" % [_status(order.status), ceili(order.remaining_seconds)]
	if is_instance_valid(_ticket_clock):
		var order := session.manager.get_order(session.manager.selected_order_id)
		if not order.is_empty():
			_ticket_clock.text = _t("Patience: %ds", "耐心剩余：%d 秒") % ceili(order.remaining_seconds)
	for id in _oven_clocks:
		if not session.food.has(id):
			continue
		var duck: Dictionary = session.food[id]
		_oven_clocks[id].text = "%s · %.1fs\n%s" % [id, float(duck.roast_seconds), session.roast_quality(duck.roast_seconds).to_upper()]
		var bar: ProgressBar = _oven_bars[id]
		bar.value = float(duck.roast_seconds)
		var fill: StyleBoxFlat = bar.get_theme_stylebox("fill")
		fill.bg_color = Color("538548") if bar.value >= 12 and bar.value < 18 else Color("e4a13e")
		if bar.value >= 18:
			fill.bg_color = Color("43271b")


func _on_focus_lost() -> void:
	session.set_paused(true)
	receiver.invalidate()
	_key_holds.clear()


func _navigate(destination: String) -> void:
	if session.navigate(destination):
		receiver.invalidate()
		_key_holds.clear()


func _select(id: String) -> void:
	if session.select_order(id):
		receiver.invalidate()
		_key_holds.clear()


func _pause() -> void:
	session.set_paused(not session.paused)
	receiver.invalidate()
	_key_holds.clear()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key := int(event.keycode)
	if not event.pressed:
		_key_holds.erase(key)
		return
	if _popup_open():
		if key == KEY_ESCAPE:
			if session.paused:
				_pause()
			else:
				_close_popup()
			get_viewport().set_input_as_handled()
		return
	if event.echo or _key_holds.has(key):
		return
	_key_holds[key] = true
	if key == KEY_ESCAPE:
		if _popup_open():
			_close_popup()
		else:
			_pause()
	elif key >= KEY_1 and key <= KEY_5:
		session.perform_action(key - KEY_1 + 1)
	elif key in [KEY_SPACE, KEY_0]:
		session.perform_action(0)
	elif key in [KEY_ENTER, KEY_KP_ENTER] and session.station == "prepare":
		session.serve_current()
	else:
		return
	get_viewport().set_input_as_handled()


func _refresh() -> void:
	var overlay_mode: String = _order_view._overlay_mode if is_instance_valid(_order_view) else ""
	_order_view = null
	_dirty = false
	_last_signature = _view_signature()
	_rail_clocks.clear()
	_oven_clocks.clear()
	_oven_bars.clear()
	_ticket_clock = null
	for child in _canvas.get_children():
		_canvas.remove_child(child)
		child.queue_free()
	_canvas.size = DESIGN_SIZE
	if session.station == "order" and session.rating.is_empty() and not session.summary_visible:
		_canvas.size = ApprovedOrderView.CANVAS_SIZE
		_order_view = ApprovedOrderView.new()
		_canvas.add_child(_order_view)
		_order_view.initialize(self)
		if overlay_mode in ["all", "detail"] and not session.paused:
			_order_view.show_overlay(overlay_mode)
		_fit()
		return
	_picture(_canvas, _textures.kitchen_background, Rect2(0, 0, 1440, 900), false)
	var shade := ColorRect.new()
	shade.color = Color(0.12, 0.06, 0.02, 0.46)
	shade.size = DESIGN_SIZE
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.add_child(shade)
	_panel(_canvas, Rect2(16, 12, 1408, 88), "navigation_selected_frame")
	_label(_canvas, "Magic Kitchen", Rect2(36, 26, 245, 36), 29, PAPER)
	_label(_canvas, _t("PEKING DUCK ROLLS", "北京烤鸭卷"), Rect2(38, 64, 240, 22), 15, PAPER)
	var names := [["order", "Orders", "点单台"], ["roast", "Roast", "烤炉台"], ["prepare", "Prepare", "料理台"]]
	for i in range(names.size()):
		var entry: Array = names[i]
		_button(_canvas, _t(entry[1], entry[2]), Rect2(300 + i * 174, 27, 160, 54), func(): _navigate(entry[0]), not session.can_interact(), session.station == entry[0])
	_button(_canvas, "EN / 中文", Rect2(838, 27, 140, 54), func(): language = "zh" if language == "en" else "en"; _dirty = true)
	_button(_canvas, _t("Resume", "继续") if session.paused else _t("Pause", "暂停"), Rect2(990, 27, 130, 54), _pause)
	_button(_canvas, _t("Restart", "重开"), Rect2(1132, 27, 130, 54), _confirm_restart)
	_label(_canvas, "%d / %d" % [session.results.size(), int(session.rules.shift_orders)], Rect2(1280, 30, 112, 48), 25, PAPER)
	_build_rail()
	if session.summary_visible:
		_build_summary()
	elif not session.rating.is_empty():
		_build_rating()
	else:
		_build_ticket()
		_build_station()
		_build_actions()
	_panel(_canvas, Rect2(24, 836, 1392, 52), "navigation_selected_frame")
	_label(_canvas, _t("PAUSED · resume to continue", "已暂停 · 点击继续") if session.paused else session.message, Rect2(40, 842, 1358, 38), 18, PAPER)
	_fit()


func _build_rail() -> void:
	var orders := session.manager.get_visible_orders()
	for i in range(4):
		var rect := Rect2(24 + i * 280, 116, 266, 84)
		if i >= orders.size():
			_panel(_canvas, rect, "order_mini_frame")
			_label(_canvas, _t("Waiting for a guest", "等待顾客到店"), Rect2(rect.position + Vector2(16, 20), Vector2(235, 35)), 17)
			continue
		var order: Dictionary = orders[i]
		var button := _button(_canvas, "", rect, func(): _select(order.order_id), not session.can_interact(), order.order_id == session.manager.selected_order_id)
		_label(button, "%s · %s" % [order.order_id, order.customer_name[language]], Rect2(16, 8, 236, 30), 20, PAPER if session.can_interact() and order.order_id == session.manager.selected_order_id else INK)
		_rail_clocks[order.order_id] = _label(button, "%s · %ds" % [_status(order.status), ceili(order.remaining_seconds)], Rect2(16, 42, 236, 27), 16, PAPER if session.can_interact() and order.order_id == session.manager.selected_order_id else INK)
	_button(_canvas, _t("All tickets", "全部订单"), Rect2(1156, 116, 260, 38), _show_orders, not session.can_interact())
	_button(_canvas, _t("Camera", "摄像头"), Rect2(1156, 164, 260, 36), receiver.toggle_camera)


func _build_ticket() -> void:
	_panel(_canvas, Rect2(24, 218, 338, 438), "order_main_frame")
	var order := session.manager.get_order(session.manager.selected_order_id)
	if order.is_empty():
		_label(_canvas, _t("No active ticket", "暂无有效订单"), Rect2(52, 248, 280, 50), 25)
		return
	_label(_canvas, order.order_id + " · " + order.customer_name[language], Rect2(52, 242, 280, 40), 24)
	_label(_canvas, order.recipe_name[language], Rect2(52, 286, 280, 36), 21)
	var entry := session.current_food()
	for i in range(5):
		var ingredient: String = session.rules.ingredient_actions[i]
		var required := false
		for item in order.ingredients:
			if item.id == ingredient:
				required = true
		var added: bool = ingredient in entry.get("ingredients", [])
		var caption: String = ("[x] " if added else "[ ] ") + session.manager.catalog.ingredients[ingredient][language]
		var y := 335 + i * 43
		var row := _button(_canvas, caption, Rect2(48, y, 290, 38), func(): session.remove_ingredient(ingredient), not (session.can_interact() and session.station == "prepare" and entry.get("stage") == "preparing" and added and ingredient != "duck_meat"))
		var row_style := StyleBoxFlat.new()
		row_style.bg_color = Color(0.9, 0.77, 0.53, 0.35) if required else Color(0, 0, 0, 0)
		row_style.set_corner_radius_all(5)
		for state in ["normal", "hover", "pressed", "disabled"]:
			row.add_theme_stylebox_override(state, row_style)
		row.add_theme_color_override("font_disabled_color", INK if required else Color("9b8063"))
		row.add_theme_font_size_override("font_size", 17)
		row.modulate = Color.WHITE if required else Color(0.75, 0.7, 0.62)
	_label(_canvas, _t("Needs: ", "要求：") + order.special_request[language], Rect2(50, 558, 288, 40), 15)
	_ticket_clock = _label(_canvas, _t("Patience: %ds", "耐心剩余：%d 秒") % ceili(order.remaining_seconds), Rect2(52, 600, 277, 30), 19)
	_button(_canvas, _t("Expand ticket", "展开小票"), Rect2(48, 668, 290, 44), _show_details, not session.can_interact())


func _build_station() -> void:
	_panel(_canvas, Rect2(384, 218, 1032, 438), "parchment_panel")
	var entry := session.current_food()
	match session.station:
		"order":
			var current_order := session.manager.get_order(session.manager.selected_order_id)
			if not current_order.is_empty():
				var portrait := AtlasTexture.new()
				portrait.atlas = _textures.portraits
				var portrait_index: int = {"customer_lin": 0, "customer_chen": 1, "customer_mei": 2}.get(current_order.portrait, 0)
				var tile := Vector2(portrait.atlas.get_width() / 3.0, portrait.atlas.get_height())
				portrait.region = Rect2(Vector2(portrait_index * tile.x, 0), tile)
				_picture(_canvas, portrait, Rect2(1052, 294, 280, 320))
			_label(_canvas, _t("At the counter", "点单柜台"), Rect2(424, 244, 550, 48), 33)
			var current := session.manager.get_order(session.manager.selected_order_id)
			var prompt: String = current.get("special_request", {"en": "The next guest is on the way.", "zh": "下一位顾客正在路上。"})[language]
			_label(_canvas, prompt, Rect2(424, 312, 580, 90), 27)
			_label(_canvas, _t("Read the ticket, accept it, then choose Roast.\nOther customers keep waiting while you cook.", "查看小票并接单，再前往烤炉台。\n制作时，其他顾客仍会继续等待。"), Rect2(424, 421, 580, 75), 22)
			_button(_canvas, _t("Accept order", "确认接单"), Rect2(424, 537, 420, 66), session.accept_current, not session.can_interact() or current.get("status") != "pending", true)
		"roast":
			_label(_canvas, _t("Two ovens · watch the heat", "双炉位 · 留意火候"), Rect2(424, 239, 920, 48), 30)
			var in_oven: Array = []
			for id in session.food:
				if session.food[id].stage == "roasting":
					in_oven.append(id)
			for i in range(2):
				var x := 424 + i * 462
				_panel(_canvas, Rect2(x, 306, 434, 148), "navigation_selected_frame")
				var oven_text := _t("Empty oven", "空炉位")
				if i < in_oven.size():
					var duck: Dictionary = session.food[in_oven[i]]
					oven_text = "%s · %.1fs\n%s" % [in_oven[i], float(duck.roast_seconds), session.roast_quality(duck.roast_seconds).to_upper()]
				var oven_clock := _label(_canvas, oven_text, Rect2(x + 26, 316, 385, 100), 27, PAPER)
				var heat := ProgressBar.new()
				heat.position = Vector2(x + 24, 426)
				heat.size = Vector2(386, 16)
				heat.max_value = float(session.rules.burnt_seconds)
				heat.show_percentage = false
				if i < in_oven.size():
					heat.value = float(session.food[in_oven[i]].roast_seconds)
				var heat_fill := StyleBoxFlat.new()
				heat_fill.bg_color = Color("538548") if heat.value >= 12 and heat.value < 18 else Color("e4a13e")
				if heat.value >= 18:
					heat_fill.bg_color = Color("43271b")
				heat.add_theme_stylebox_override("fill", heat_fill)
				_canvas.add_child(heat)
				if i < in_oven.size():
					_oven_clocks[in_oven[i]] = oven_clock
					_oven_bars[in_oven[i]] = heat
			_label(_canvas, _t("Raw <12s  |  Cooked 12–<18s  |  Burnt ≥18s", "未熟 <12 秒  |  适熟 12–<18 秒  |  烤焦 ≥18 秒"), Rect2(424, 478, 920, 40), 23)
			_label(_canvas, _t("Selected ticket: ", "当前订单：") + str(entry.get("stage", "waiting")).replace("_", " "), Rect2(424, 538, 900, 40), 24)
			_button(_canvas, _t("Go to Prepare", "进入料理台"), Rect2(1004, 582, 355, 49), func(): _navigate("prepare"), not session.can_interact())
		"prepare":
			_label(_canvas, _t("Build this guest's wrap", "制作这位顾客的烤鸭卷"), Rect2(424, 237, 920, 48), 30)
			var added: Array = entry.get("ingredients", [])
			if entry.get("stage") in ["wrapping", "ready"]:
				_picture(_canvas, _textures.wrap, Rect2(698, 298, 380, 240))
			else:
				for i in range(5):
					var ingredient: String = session.rules.ingredient_actions[i]
					var card := _button(_canvas, "", Rect2(414 + i * 196, 310, 180, 180), func(): session.perform_action(i + 1), not session.action_available(i + 1), ingredient in added)
					_picture(card, _textures[ingredient], Rect2(22, 10, 136, 112))
					_label(card, "%d · %s" % [i + 1, session.manager.catalog.ingredients[ingredient][language]], Rect2(8, 120, 164, 54), 15)
			_label(_canvas, _recipe_progress_text(), Rect2(424, 510, 940, 35), 20)
			_label(_canvas, _t("Stage: ", "状态：") + str(entry.get("stage", "waiting")).replace("_", " "), Rect2(424, 555, 500, 36), 22)
			_button(_canvas, _t("Complete order", "完成订单"), Rect2(1004, 578, 355, 54), session.serve_current, not session.can_interact() or entry.get("stage") != "ready", true)


func _build_actions() -> void:
	var numbers: Array = [1, 2, 3] if session.station == "roast" else ([1, 2, 3, 4, 5, 0] if session.station == "prepare" else [])
	if numbers.is_empty():
		_label(_canvas, _t("One order, one journey: accept → roast → slice → roll → serve", "同一张订单：接单 → 烤鸭 → 片鸭 → 卷制 → 交付"), Rect2(390, 700, 1014, 54), 25, PAPER)
		_label(_canvas, _t("Click tickets to switch. Pause stops all kitchen timers.", "点击小票切换订单。暂停会停止所有制作与等待计时。"), Rect2(390, 758, 1014, 42), 21, PAPER)
	else:
		var width := 1008.0 / numbers.size()
		for i in range(numbers.size()):
			var number: int = numbers[i]
			var caption := _t("Roll · Space", "握拳卷制 · 空格") if number == 0 else str(number)
			if session.station == "roast":
				caption += " · " + [_t("Put in", "放入"), _t("Take out", "取出"), _t("Slice", "片鸭")][number - 1]
			else:
				if number > 0:
					caption += " · " + session.manager.catalog.ingredients[session.rules.ingredient_actions[number - 1]][language]
			var card := _button(_canvas, "", Rect2(384 + i * width, 676, width - 12, 142), func(): session.perform_action(number), not session.action_available(number))
			_picture(card, _textures["hand_%d" % number], Rect2((width - 98) / 2.0, 8, 86, 88))
			_label(card, caption, Rect2(9, 96, width - 30, 42), 14)
	_camera_line = _label(_canvas, receiver.status, Rect2(28, 754, 325, 66), 15, PAPER)


func _build_rating() -> void:
	var result := session.rating
	_panel(_canvas, Rect2(144, 220, 1152, 585), "parchment_panel")
	_label(_canvas, "%s · %s" % [result.order_id, result.customer_name[language]], Rect2(190, 248, 1010, 55), 33)
	_picture(_canvas, _textures.wrap, Rect2(210, 344, 310, 240))
	_label(_canvas, "%s · %d / 100" % [result.reaction, int(result.total)], Rect2(560, 327, 680, 72), 40)
	_label(_canvas, _t("Ordering %.0f   Roasting %d   Preparation %d", "点单 %.0f   烘烤 %d   料理 %d") % [float(result.wait_score), int(result.roast_score), int(result.prep_score)], Rect2(560, 423, 680, 60), 25)
	_label(_canvas, _t("The three station scores are averaged.\nEach ingredient matches or loses 20 preparation points.", "三站分数取平均。\n五种食材逐项核对，每项正确得 20 料理分。"), Rect2(560, 510, 650, 75), 21)
	_button(_canvas, _t("Return to work", "返回工作区") if session.can_return() else _t("Tasting…", "品尝中…"), Rect2(500, 674, 440, 70), _return_to_work, not session.can_return(), true)


func _return_to_work() -> void:
	if session.return_to_work():
		receiver.invalidate()


func _build_summary() -> void:
	var result := session.summary()
	_panel(_canvas, Rect2(220, 234, 1000, 560), "parchment_panel")
	_label(_canvas, _t("Shift complete", "营业结束"), Rect2(280, 270, 880, 65), 40)
	_label(_canvas, _t("Goal reached!", "达成目标！") if result.success else _t("Try another shift", "再挑战一轮"), Rect2(280, 354, 880, 55), 30)
	_label(_canvas, _t("Served %d · Expired %d\nAverage %.1f · Total %d\nGoal: at least 3 served, average 70 or more", "交付 %d 单 · 过期 %d 单\n平均 %.1f 分 · 总分 %d\n目标：至少交付 3 单，交付平均分不低于 70") % [int(result.served), int(result.expired), float(result.average), int(result.total)], Rect2(280, 433, 880, 140), 27)
	_button(_canvas, _t("Start a new shift", "开始新一轮"), Rect2(500, 663, 440, 70), _restart, false, true)


func _restart() -> void:
	session.restart()
	receiver.invalidate()
	_key_holds.clear()


func _confirm_restart() -> void:
	var was_paused := session.paused
	session.set_paused(true)
	receiver.invalidate()
	var dialog := ConfirmationDialog.new()
	dialog.title = _t("Restart shift?", "重新营业？")
	dialog.dialog_text = _t("Clear all orders, food, ovens and scores?", "清空所有订单、食材、炉位和分数？")
	dialog.confirmed.connect(func(): _restart(); dialog.queue_free())
	dialog.canceled.connect(func(): session.set_paused(was_paused); dialog.queue_free())
	add_child(dialog)
	dialog.popup_centered(Vector2i(460, 170))


func _show_orders() -> void:
	if session.station == "order" and is_instance_valid(_order_view):
		_order_view.show_overlay("all")
	else:
		_show_popup(true)


func _show_details() -> void:
	if session.station == "order" and is_instance_valid(_order_view):
		_order_view.show_overlay("detail")
	else:
		_show_popup(false)


func _close_popup() -> void:
	if is_instance_valid(_order_view):
		_order_view.close_overlay()
	if is_instance_valid(_popup):
		_popup.hide()
	if is_instance_valid(_popup_scrim):
		_popup_scrim.hide()
	_popup_clocks.clear()
	receiver.invalidate()
	_key_holds.clear()


func _show_popup(all_orders: bool) -> void:
	if not session.can_interact():
		return
	if is_instance_valid(_popup):
		_popup.queue_free()
	if is_instance_valid(_popup_scrim):
		_popup_scrim.queue_free()
	_popup_clocks.clear()
	# In-scene overlay: a native PopupPanel steals the window focus and pauses the shift.
	_popup_scrim = ColorRect.new()
	_popup_scrim.color = Color(0.08, 0.04, 0.02, 0.72)
	_popup_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_popup_scrim)
	_popup = PanelContainer.new()
	_popup.custom_minimum_size = Vector2(1000, 650 if all_orders else 340)
	_popup.size = _popup.custom_minimum_size
	_popup.add_theme_stylebox_override("panel", _style("parchment_panel"))
	add_child(_popup)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 30)
	_popup.add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	margin.add_child(layout)
	var title := Label.new()
	title.text = _t("All tickets", "全部订单") if all_orders else _t("Ticket details", "订单详情")
	title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", INK)
	layout.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(880, 360 if all_orders else 140)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 14)
	scroll.add_child(list)
	var orders: Array = session.manager.get_visible_orders() if all_orders else [session.manager.get_order(session.manager.selected_order_id)]
	for order in orders:
		if order.is_empty():
			continue
		var button := Button.new()
		button.custom_minimum_size = Vector2(880, 52)
		button.add_theme_font_override("font", _font)
		button.add_theme_font_size_override("font_size", 21)
		for state in ["normal", "hover", "pressed", "disabled"]:
			button.add_theme_stylebox_override(state, _style("navigation_paper_frame"))
		button.add_theme_color_override("font_color", INK)
		button.add_theme_color_override("font_hover_color", INK)
		button.add_theme_color_override("font_pressed_color", INK)
		button.pressed.connect(func(): _select(order.order_id); _close_popup())
		list.add_child(button)
		_popup_clocks[order.order_id] = button
		var text := Label.new()
		text.add_theme_font_override("font", _font)
		text.add_theme_font_size_override("font_size", 20)
		text.add_theme_color_override("font_color", INK)
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.text = order.special_request[language] + "\n"
		for item in order.ingredients:
			text.text += "%s ×%d   " % [session.manager.catalog.ingredients[item.id][language], int(item.quantity)]
		list.add_child(text)
	var close := Button.new()
	close.text = _t("Close · timers keep running", "关闭 · 计时仍在继续")
	close.custom_minimum_size.y = 52
	close.add_theme_font_override("font", _font)
	close.add_theme_font_size_override("font_size", 21)
	close.add_theme_color_override("font_color", INK)
	close.add_theme_color_override("font_hover_color", INK)
	close.add_theme_color_override("font_pressed_color", INK)
	for state in ["normal", "hover", "pressed"]:
		close.add_theme_stylebox_override(state, _style("navigation_paper_frame"))
	close.pressed.connect(_close_popup)
	layout.add_child(close)
	receiver.invalidate()
	_key_holds.clear()
	_fit()
	_refresh_timers()
	close.grab_focus()
	# Containers settle their minimum sizes on the next frame; centre the final bounds.
	_fit.call_deferred()


func _recipe_progress_text() -> String:
	var order := session.manager.get_order(session.manager.selected_order_id)
	var added: Array = session.current_food().get("ingredients", [])
	var required: Array = []
	for item in order.get("ingredients", []):
		if item.id != "wrapper":
			required.append(item.id)
	var matched := 0
	var extra := 0
	for ingredient in added:
		if ingredient in required:
			matched += 1
		else:
			extra += 1
	return _t("Recipe: %d / %d · Extra: %d · click a checked side to remove it", "配方完成：%d / %d · 多加：%d · 点击已勾选配菜可移除") % [matched, required.size(), extra]


func _style(texture: String) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = _textures[texture]
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 18)
		style.set_content_margin(side, 8)
	return style


func _panel(parent: Control, rect: Rect2, texture: String) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(texture))
	parent.add_child(panel)
	return panel


func _button(parent: Control, text: String, rect: Rect2, callback: Callable, disabled: bool = false, selected: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.disabled = disabled
	button.add_theme_font_override("font", _font)
	button.add_theme_font_size_override("font_size", 21)
	button.add_theme_color_override("font_color", PAPER if selected else INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_disabled_color", Color("8d7962"))
	for state in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, _style("navigation_selected_frame" if selected and state != "disabled" else "navigation_paper_frame"))
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _label(parent: Control, text: String, rect: Rect2, font_size: int, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_override("font", ThemeDB.fallback_font if text == "Magic Kitchen" else _font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = text != "Magic Kitchen"
	if text == "Magic Kitchen":
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _picture(parent: Control, texture: Texture2D, rect: Rect2, preserve: bool = true) -> void:
	var picture := TextureRect.new()
	picture.position = rect.position
	picture.size = rect.size
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if preserve else TextureRect.STRETCH_SCALE
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(picture)


func _status(status: String) -> String:
	var names := {"pending": ["Awaiting acceptance", "待接单"], "accepted": ["Accepted", "已接单"], "roasting": ["Roasting / slicing", "烘烤与片鸭"], "preparing": ["Preparing", "料理中"], "ready_to_serve": ["Ready to serve", "待交付"]}
	return names.get(status, [status, status])[1 if language == "zh" else 0]


func _t(en: String, zh: String) -> String:
	return zh if language == "zh" else en
