extends SceneTree

const Station = preload("res://scenes/cooking_station/cooking_station_ui.tscn")
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
	current_scene = station
	_check(load("res://scenes/cooking_station/cooking_station_layered.tscn") != null, "legacy scene opens without missing assets")
	_check(station.view.get_node_or_null("Game/PlateFeedback") == null, "obsolete plate feedback panel is removed")
	_check(station.view.get_node_or_null("Game/StatusStrip/CameraStatus") == null, "duplicate camera status is removed")
	_check(station.view.camera_button.text == "Restart Camera", "camera button offers restart")
	station.set_gesture_status("waiting for camera bridge on UDP 4242")
	_check(station.view.feedback.text == "Gesture Status: Waiting for input", "camera status starts waiting")
	station.set_gesture_status("camera could not be opened")
	_check(station.view.feedback.text == "Gesture Status: Camera unavailable", "camera failure appears in left status")
	station.set_gesture_status("camera connected · show a stable gesture")
	_check(station.view.feedback.text == "Gesture Status: Waiting for input", "connected camera waits for gesture")
	station.receive_action("add_duck", true)
	_check(station.view.feedback.text == "Gesture Status: Recognized", "recognized gesture appears in left status")
	station.receive_action("add_duck", false)
	_check(station.view.feedback.text == "Gesture Status: Waiting for input", "released gesture returns to waiting")
	station.set_gesture_status("camera bridge stopped")
	_check(station.view.feedback.text == "Gesture Status: Camera unavailable", "disconnected camera appears unavailable")
	station.set_gesture_status("waiting for camera bridge on UDP 4242")
	_check(station.view.get_node("Game/WorkbenchDecor/NumberBadges/OrderThumbnail1") is TextureRect, "order number is a UI control")
	_check(station.view.get_node("Gestures/Card1/Gesture1") is TextureRect, "gesture art is grouped into its card")
	var reused_icons := {
		"Game/Queue1/IconWrap": "Game/OrderTicket/OrderWrapIcon",
		"Game/Queue1/IconCucumber": "Game/OrderTicket/IconCucumber",
		"Game/Queue1/IconSauce": "Game/OrderTicket/IconSauce",
		"Game/Queue2/IconScallion": "Game/OrderTicket/IconScallion",
		"Game/Queue2/IconHawthorn": "Game/OrderTicket/IconHawthorn",
		"Game/Queue3/IconCucumber": "Game/OrderTicket/IconCucumber",
	}
	for queue_path in reused_icons:
		_check(station.view.get_node(queue_path).texture == station.view.get_node(reused_icons[queue_path]).texture, queue_path + " reuses Order 01 icon")
	station.order_completed.connect(func(order: Dictionary): submissions.append(order))
	await _click(station.view.get_node("Game/Queue1").get_global_rect().get_center())
	_check(station.order_id == "02", "clicking Order 02 selects its recipe")
	_check(station.required == ["duck", "cucumber", "sauce"], "large ticket shows Order 02 recipe")
	_check(station.view.get_node("Game/Queue1/Heading").text == "Order 01", "previous large ticket moves into the small slot")
	_check(station.view.get_node("Game/Queue1/Items/Row5").visible, "Order 01 fits all its ingredients in the small ticket")
	_check(not station.view.get_node("Game/OrderTicket/Hawthorn").visible, "unneeded ingredient is absent from large ticket")
	_check(station.view.get_node("Game/OrderTicket/Cucumber").position.y == 280, "large ticket compacts required ingredients")
	station.receive_action("add_cucumber", true)
	_check(station.added == ["cucumber"], "gesture 4 can add cucumber before duck")
	station.receive_action("add_cucumber", false)
	await _click(station.view.get_node("Game/Queue2").get_global_rect().get_center())
	_check(station.order_id == "03" and station.added.is_empty(), "another order starts with its own empty plate")
	await _click(station.view.get_node("Game/Queue1").get_global_rect().get_center())
	await _click(station.view.get_node("Game/Queue2").get_global_rect().get_center())
	_check(station.order_id == "02" and station.added == ["cucumber"], "switching back restores Order 02 ingredients")
	station._add_ingredient("sauce")
	station._add_ingredient("duck")
	station._roll()
	_check(station.rolled, "Order 02 rolls with duck added last")
	await _click(station.view.get_node("Game/Queue1").get_global_rect().get_center())
	await _click(station.view.get_node("Game/Queue1").get_global_rect().get_center())
	_check(station.order_id == "02" and station.rolled, "switching back restores the completed wrap on Order 02")
	var first_ingredients: Array[String] = ["duck", "cucumber", "scallion", "sauce"]
	station.set_order("01", first_ingredients)
	station.receive_action("add_duck", true)
	station.receive_action("add_duck", true)
	_check(station.added.size() == 1, "a held gesture adds only once")
	var duck_badge: TextureRect = station.view.get_node("Game/WorkbenchDecor/NumberBadges/OrderThumbnail1")
	_check(is_equal_approx(duck_badge.scale.x, 1.1), "recognized duck badge grows by 10 percent")
	_check(duck_badge.self_modulate == Color(1.08, 1.04, 0.86), "recognized duck badge uses a warm yellow tint")
	_check(station.view.get_node("Gestures/Card1/Gesture1").self_modulate == Color(1.12, 1.06, 0.82), "recognized hand icon brightens in warm yellow")
	_check(station.view.get_node("Gestures/Card1").self_modulate == Color(1.08, 1.04, 0.90), "matching bottom card brightens")
	_check(station.view.get_node("Gestures/Card2").self_modulate == Color.WHITE, "unmatched bottom card keeps its color")
	station.receive_action("add_duck", false)
	_check(is_equal_approx(duck_badge.scale.x, 1.1), "latest recognized ingredient remains highlighted after release")
	station.receive_action("add_cucumber", true)
	station.receive_action("add_scallion", true)
	_check(is_equal_approx(station.view.get_node("Game/WorkbenchDecor/NumberBadges/OrderThumbnail3").scale.x, 1.1), "current scallion gesture highlights only its badge")
	_check(duck_badge.scale == Vector2.ONE and duck_badge.self_modulate == Color.WHITE, "previously added ingredient badge stays original")
	_check(station.view.get_node("Gestures/Card1").self_modulate == Color.WHITE and station.view.get_node("Gestures/Card2").self_modulate == Color(1.08, 1.04, 0.90), "side gesture highlights only the middle bottom card")
	station.receive_action("add_hawthorn", true)
	station.receive_action("add_sauce", true)
	for i in range(1, 6):
		var number_badge: TextureRect = station.view.get_node("Game/WorkbenchDecor/NumberBadges/OrderThumbnail" + str(i))
		var gesture_icon: TextureRect = station.view.get_node("Gestures/" + ("Card1" if i == 1 else "Card2") + "/Gesture" + str(i))
		_check(number_badge.self_modulate == (Color(1.08, 1.04, 0.86) if i == 5 else Color.WHITE), "only active badge %d receives warm tint" % i)
		_check(gesture_icon.self_modulate == (Color(1.12, 1.06, 0.82) if i == 5 else Color.WHITE), "only active gesture %d receives warm tint" % i)
	station.receive_action("roll_wrap", true)
	_check(station.view.get_node("Gestures/Card3/GestureFist").self_modulate == Color(1.12, 1.06, 0.82), "fist gesture brightens in warm yellow")
	_check(station.view.get_node("Gestures/Card3").self_modulate == Color(1.08, 1.04, 0.90), "fist gesture highlights its bottom card")
	_check(station.view.get_node("Gestures/Card2").self_modulate == Color.WHITE, "middle card returns to its original color on fist")
	_check(not station.rolled, "incorrect ingredient prevents rolling")
	station._undo() # Sauce is the most recently added item.
	station._undo() # Remove the incorrect hawthorn.
	station._add_ingredient("sauce")
	station.receive_action("roll_wrap", false)
	station.receive_action("roll_wrap", true)
	_check(station.rolled, "matching order rolls")
	_check(station.view.get_node("Game/RolledPlate").visible, "finished wrap appears after rolling")
	_check(not station.view.get_node("Game/Plate").visible, "wrapper plate hides after rolling")
	_check(station.view.get_node("Game/OrderTicket/DuckCheck").text == "☑︎", "wrap is checked only after rolling")
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
	var point: Vector2 = station.view.ingredient_buttons[2].get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	Input.parse_input_event(motion)
	await process_frame
	_check(station.view.ingredient_buttons[2].modulate == Color.WHITE, "hover leaves ingredient tray unchanged")
	_check(station.view.ingredient_buttons[2].get_theme_stylebox("hover") == station.view.ingredient_buttons[2].get_theme_stylebox("normal"), "ingredient tray has no hover overlay")
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
	_check(station.view.get_node("Game/WorkbenchDecor/NumberBadges/OrderThumbnail4").self_modulate == Color.WHITE, "mouse click does not highlight a gesture badge")
	_check(station.view.order_checks[2].text == "☑︎", "order checklist updates")
	var all_ingredients: Array[String] = ["duck", "hawthorn", "cucumber", "scallion", "sauce"]
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
		_check(card.size.y == 157, "gesture card height")
		_check(card.position.x == [14, 489, 968][i - 1], "gesture card position")
		_check(card.get_node("Title").get_theme_font_size("font_size") >= 22, "gesture title font size")
		_check(card.get_node("Status").get_theme_font_size("font_size") == 18, "gesture status font size")
	_check(station.view.get_node("Top/Pause").size == Vector2(61, 61), "pause button dimensions")
	_check(station.view.get_node("Top/Order").size == Vector2(234, 69), "station button dimensions")
	_check(station.view.gesture_card_buttons.size() == 2, "duck and roll cards are clickable without a sequential side-card overlay")
	var card_order: Array[String] = ["duck", "cucumber"]
	station.set_order("04", card_order)
	await _click(station.view.side_ingredient_buttons["cucumber"].get_global_rect().get_center())
	_check(station.added == ["cucumber"], "specific side gesture adds cucumber first")
	await _click(station.view.gesture_card_buttons[0].get_global_rect().get_center())
	_check("duck" in station.added, "duck gesture card adds duck after another ingredient")
	await _click(station.view.gesture_card_buttons[1].get_global_rect().get_center())
	_check(station.rolled, "roll gesture card completes ingredients added in any order")
	station.set_order("03", all_ingredients)
	var badge_indices := {"duck": 1, "hawthorn": 2, "scallion": 3, "cucumber": 4, "sauce": 5}
	for ingredient in all_ingredients:
		station._add_ingredient(ingredient)
		_check(station.view.get_node("Game/Fillings/" + ingredient.capitalize()).visible, ingredient + " filling appears on plate")
		var badge: TextureRect = station.view.get_node("Game/WorkbenchDecor/NumberBadges/OrderThumbnail" + str(badge_indices[ingredient]))
		_check(badge.scale == Vector2.ONE and badge.self_modulate == Color.WHITE, ingredient + " number stays original after manual addition")
	_check(not station.view.get_node("Game/OrderTicket/DuckCheck").text == "☑︎", "wrap is unchecked before rolling")
	await _click(station.view.gesture_card_buttons[1].get_global_rect().get_center())
	_check(station.rolled, "roll gesture card responds to mouse")
	for ingredient in all_ingredients:
		_check(not station.view.get_node("Game/Fillings/" + ingredient.capitalize()).visible, ingredient + " filling hides when rolled")
	await _click(station.view.submit_button.get_global_rect().get_center())
	await process_frame
	await process_frame
	_check(submissions.size() == 1, "submission is emitted once")
	_check(root.get_node_or_null("RatingPlaceholder") != null, "complete button opens black rating placeholder")
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
