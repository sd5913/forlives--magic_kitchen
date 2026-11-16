extends SceneTree
## Rendered UI checks. Run without --headless for screenshots.

const Station = preload("res://scenes/orders/order_station.tscn")
var failures := 0
var checks := 0
var station: Control


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func _frames() -> void:
	await process_frame
	await process_frame
	await process_frame


func _click(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	await process_frame
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = true
	root.push_input(event, true)
	await process_frame
	event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = false
	root.push_input(event, true)
	await _frames()


func _shot(filename: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var directory := OS.get_environment("MAGIC_KITCHEN_SCREENSHOT_DIR")
	if directory.is_empty():
		directory = OS.get_user_data_dir().path_join("order_station_checks")
	DirAccess.make_dir_recursive_absolute(directory)
	var image := root.get_texture().get_image()
	_check(image.save_png(directory.path_join(filename)) == OK, "save screenshot " + filename)


func _check_text_layout(node: Node) -> void:
	if node is Label and node.has_meta("layout_rect"):
		var expected: Rect2 = node.get_meta("layout_rect")
		_check(node.position.is_equal_approx(expected.position), "label position " + node.text)
		_check(node.size.is_equal_approx(expected.size), "label bounds " + node.text)
		var font: Font = node.get_theme_font("font")
		var font_size: int = node.get_theme_font_size("font_size")
		for line in node.text.split("\n"):
			_check(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= node.size.x + 1, "text fits width " + line)
	for child in node.get_children():
		_check_text_layout(child)


func _button_rects() -> Dictionary:
	var result := {}
	for key in station._buttons:
		result[key] = station._buttons[key].get_global_rect()
	return result


func _run() -> void:
	root.size = Vector2i(1440, 900)
	station = Station.instantiate()
	root.add_child(station)
	station.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await _frames()
	_check(station.language == "en", "English default")
	_check(station.manager.get_visible_orders().size() == 1, "initial guest")
	_check(station._textures.size() == 3 and station._atlas != null, "all local art loaded")
	_check(station._background.get_width() > 0 and station._panel_tiles.size() == 4, "background and all panel tiles loaded")
	_check(station._atlas.get_image().detect_alpha() != Image.ALPHA_NONE, "food sprite sheet has transparency")
	var portraits: Texture2D = load("res://assets/ui/orders/customer_portraits.png")
	_check(portraits.get_image().detect_alpha() != Image.ALPHA_NONE, "customer sprite sheet has transparency")
	_check_text_layout(station._canvas)
	var english_rects := _button_rects()
	await _shot("orders_english.png")
	var initial_id: String = station.manager.selected_order_id
	await _click(station._buttons["language"])
	_check(station.manager.selected_order_id == initial_id, "same selected ticket across translation")
	_check_text_layout(station._canvas)
	for key_name in english_rects:
		_check(station._buttons[key_name].get_global_rect().is_equal_approx(english_rects[key_name]), "bilingual geometry " + key_name)
	await _shot("orders_chinese_same_ticket.png")
	await _click(station._buttons["language"])
	await _click(station._buttons["accept"])
	var first: Dictionary = station.manager.get_visible_orders()[0]
	_check(first["status"] == "accepted", "mouse accepts ticket")
	await _click(station._buttons["next_guest"])
	_check(station.manager.get_visible_orders().size() == 2, "mouse creates second guest")
	await _click(station._buttons["language"])
	_check(station.language == "zh", "language button changes view")
	_check(station.manager.get_order(first["order_id"])["status"] == "accepted", "language change preserves state")
	await _shot("orders_chinese.png")
	await _click(station._buttons["accept"])
	await _click(station._buttons["next_guest"])
	await _click(station._buttons["accept"])
	await _click(station._buttons["next_guest"])
	_check(station.manager.get_active_count() == 3, "three orders accepted")
	_check_text_layout(station._canvas)
	_check(station._buttons["accept"].disabled, "capacity disables acceptance")
	await _shot("orders_capacity.png")
	await _click(station._buttons["pause"])
	_check(station.paused, "pause click")
	var clock: float = station.manager.elapsed_seconds
	await create_timer(0.2).timeout
	_check(is_equal_approx(clock, station.manager.elapsed_seconds), "pause freezes waiting clock")
	_check(station._buttons["next_guest"].disabled, "paused arrival disabled")
	await _click(station._buttons["restart"])
	await _frames()
	var confirmation: ConfirmationDialog
	for child in station.get_children():
		if child is ConfirmationDialog:
			confirmation = child
	_check(is_instance_valid(confirmation), "restart asks for confirmation")
	if is_instance_valid(confirmation):
		confirmation.canceled.emit()
	await _frames()
	_check(station.manager.get_active_count() == 3, "cancel restart preserves orders")
	station.manager.advance_time(500)
	await _frames()
	_check(station.manager.get_visible_orders().is_empty(), "expiry renders empty state")
	await _shot("orders_empty.png")
	await _click(station._buttons["pause"])
	station._buttons["next_guest"].grab_focus()
	var key := InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	root.push_input(key, true)
	await process_frame
	key = InputEventKey.new()
	key.keycode = KEY_SPACE
	root.push_input(key, true)
	await _frames()
	_check(station.manager.get_visible_orders().size() == 1, "keyboard Space activates focused arrival button")
	root.size = Vector2i(960, 540)
	await _frames()
	_check(station._canvas.get_global_rect().end.x <= 961, "960px layout fits horizontally")
	_check(station._canvas.get_global_rect().end.y <= 541, "540px layout fits vertically")
	await _shot("orders_small.png")
	station.queue_free()
	await _frames()
	var workbench: Control = load("res://scenes/workbench.tscn").instantiate()
	root.add_child(workbench)
	await _frames()
	await _click(workbench.get_node("OrderPanel/OpenOrders"))
	var panel = workbench.get_node("OrderPanel")
	_check(is_instance_valid(panel._station), "workbench opens station")
	_check(panel._station.visible, "expanded station visible")
	await _shot("orders_workbench.png")
	await _click(panel._station._buttons["close"])
	_check(not panel._station.visible, "close returns to workbench")
	await _click(workbench.get_node("OrderPanel/OpenOrders"))
	_check(panel._station.manager.get_visible_orders().size() == 1, "reopen preserves queue")
	workbench.queue_free()
	await _frames()
	print("Order station UI: %d checks, %d failures." % [checks, failures])
	quit(1 if failures else 0)
