extends SceneTree

const Station = preload("res://scenes/cooking_station/cooking_station_layered.tscn")
var failures := 0
var submissions: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# This contributor scene has its own canvas, independent of the default counter.
	root.content_scale_size = Vector2i(1440, 900)
	root.size = Vector2i(1440, 900)
	var station = Station.instantiate()
	root.add_child(station)
	station.order_completed.connect(func(order: Dictionary): submissions.append(order))
	station.receive_action("add_duck", true)
	station.receive_action("add_duck", true)
	_check(station.added.size() == 1, "a held gesture adds only once")
	station.receive_action("add_duck", false)
	station.receive_action("add_cucumber", true)
	station.receive_action("add_scallion", true)
	station.receive_action("add_radish", true)
	station.receive_action("add_sauce", true)
	station.receive_action("roll_wrap", true)
	_check(not station.rolled, "incorrect ingredient prevents rolling")
	station._undo() # Sauce is the most recently added item.
	station._undo() # Remove the incorrect radish.
	station._add_ingredient("sauce")
	station.receive_action("roll_wrap", false)
	station.receive_action("roll_wrap", true)
	_check(station.rolled, "matching order rolls")
	station._submit()
	station._submit()
	_check(submissions.size() == 1, "submission is emitted only once")
	if not submissions.is_empty():
		_check(submissions[0].order_id == "01", "submission retains order ID")
	var next_ingredients: Array[String] = ["duck", "cucumber"]
	station.set_order("02", next_ingredients)
	station._toggle_pause()
	station.receive_action("add_duck", true)
	_check(station.added.is_empty(), "paused station ignores actions")
	station._toggle_pause()
	station.receive_action("add_duck", true)
	_check(station.added == ["duck"], "fresh action works after resume")
	# Exercise the actual scaled hit area, including input delivery to the UI.
	await process_frame
	_check(root.content_scale_size == Vector2i(1440, 900), "runtime viewport matches the cooking canvas")
	_check(station.size == Vector2(1440, 900), "station fills the runtime viewport")
	_check(station.view.scale.is_equal_approx(Vector2.ONE), "canvas has no extra downscaling at the design size")
	var point: Vector2 = station.view.canvas.get_global_transform() * Vector2(672, 360)
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	Input.parse_input_event(motion)
	await process_frame
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = point
	press.global_position = point
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = point
	release.global_position = point
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame
	_check("cucumber" in station.added, "clicking the cucumber art adds cucumber")
	_check(station.view.order_checks[1].text == "☑", "order checklist updates")
	var all_ingredients: Array[String] = ["duck", "cucumber", "scallion", "radish", "sauce"]
	station.set_order("03", all_ingredients)
	for i in range(station.view.ingredient_buttons.size()):
		await _click(station.view.ingredient_buttons[i].get_global_rect().get_center())
		_check(all_ingredients[i] in station.added, "food button adds " + all_ingredients[i])
	_check(station.view.canvas.size == Vector2(1440, 900), "design canvas is 1440 x 900")
	_check(station.view.get_node("Top").size == Vector2(1440, 100), "top area dimensions")
	_check(station.view.get_node("Game").size == Vector2(1440, 560), "game area dimensions")
	_check(station.view.get_node("Gestures").size == Vector2(1440, 240), "gesture area dimensions")
	for i in range(1, 4):
		var card: Control = station.view.get_node("Gestures/Card" + str(i))
		_check(card.size == Vector2(432, 160), "gesture card dimensions")
		_check(card.position.x == 48 + (i - 1) * 456, "gesture card spacing")
		_check(card.get_node("Icon").size == Vector2(96, 96), "gesture icon dimensions")
		_check(card.get_node("Title").get_theme_font_size("font_size") == 28, "gesture title font size")
		_check(card.get_node("Status").get_theme_font_size("font_size") == 18, "gesture status font size")
	_check(station.view.get_node("Top/Pause").size == Vector2(56, 56), "pause button dimensions")
	_check(station.view.get_node("Top/Order").size == Vector2(216, 56), "station button dimensions")
	_check(station.view.gesture_card_buttons.size() == 3, "three gesture cards have click overlays")
	var card_order: Array[String] = ["duck", "cucumber"]
	station.set_order("04", card_order)
	await _click(station.view.gesture_card_buttons[0].get_global_rect().get_center())
	_check("duck" in station.added, "first gesture card click adds duck")
	await _click(station.view.gesture_card_buttons[1].get_global_rect().get_center())
	_check("cucumber" in station.added, "second gesture card click adds next required side")
	await _click(station.view.gesture_card_buttons[2].get_global_rect().get_center())
	_check(station.rolled, "third gesture card click rolls wrap")
	station.set_order("03", all_ingredients)
	for ingredient in all_ingredients:
		station._add_ingredient(ingredient)
	await _click(station.view.roll_button.get_global_rect().get_center())
	_check(station.rolled, "roll button responds to mouse")
	await _click(station.view.submit_button.get_global_rect().get_center())
	_check(station.completed, "complete button responds to mouse")
	station.queue_free()
	print("Cooking station checks: %d failure(s)" % failures)
	quit(1 if failures else 0)


func _check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error("FAILED: " + description)


func _click(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	Input.parse_input_event(motion)
	await process_frame
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = point
	press.global_position = point
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = point
	release.global_position = point
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame
