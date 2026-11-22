extends Control

const DESIGN_SIZE := Vector2(1440, 900)

var station
var canvas: Control
var ingredient_buttons: Array[Button] = []
var order_rows: Array[Label] = []
var order_checks: Array[Label] = []
var plate_labels: Array[Label] = []
var pause_button: Button
var roll_button: Button
var submit_button: Button
var undo_button: Button
var feedback: Label
var gesture_status: Label
var camera_button: Button
var gesture_card_buttons: Array[Button] = []


func initialize(owner_station: Control) -> void:
	station = owner_station
	canvas = self
	for ingredient in ["Duck", "Cucumber", "Scallion", "Radish", "Sauce"]:
		var button: Button = get_node("Game/" + ingredient)
		ingredient_buttons.append(button)
		button.pressed.connect(station._add_ingredient.bind(ingredient.to_lower()))
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.mouse_entered.connect(_set_food_hover.bind(button, true))
		button.mouse_exited.connect(_set_food_hover.bind(button, false))
		button.button_down.connect(_set_food_pressed.bind(button, true))
		button.button_up.connect(_set_food_pressed.bind(button, false))
		order_rows.append(get_node("Game/OrderTicket/" + ingredient))
		order_checks.append(get_node("Game/OrderTicket/" + ingredient + "Check"))
	for i in range(5):
		plate_labels.append(get_node("Game/PlateFeedback/Line" + str(i + 1)))
	pause_button = $Top/Pause
	roll_button = $Game/Roll
	undo_button = $Game/Undo
	submit_button = $Game/Complete
	feedback = $Game/StatusStrip/Feedback
	gesture_status = $Game/StatusStrip/CameraStatus
	camera_button = $Game/StatusStrip/CameraButton
	pause_button.pressed.connect(station._toggle_pause)
	roll_button.pressed.connect(station._roll)
	undo_button.pressed.connect(station._undo)
	submit_button.pressed.connect(station._submit)
	camera_button.pressed.connect(station._toggle_camera)
	$Top/Order.pressed.connect(_navigate.bind("order"))
	$Top/Roasting.pressed.connect(_navigate.bind("roasting"))
	$Top/Cooking.pressed.connect(_navigate.bind("cooking"))
	_add_gesture_card_button($Gestures/Card1, station._add_ingredient.bind("duck"), "Simulate one-finger gesture")
	_add_gesture_card_button($Gestures/Card2, _simulate_next_side, "Simulate the next required 2–5 finger gesture")
	_add_gesture_card_button($Gestures/Card3, station._roll, "Simulate fist gesture")
	station.resized.connect(_fit_canvas)
	_fit_canvas()


func _add_gesture_card_button(card: Control, callback: Callable, tooltip: String) -> void:
	var button := Button.new()
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.flat = true
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.tooltip_text = tooltip
	button.pressed.connect(callback)
	button.mouse_entered.connect(_set_card_hover.bind(card, true))
	button.mouse_exited.connect(_set_card_hover.bind(card, false))
	card.add_child(button)
	gesture_card_buttons.append(button)


func _simulate_next_side() -> void:
	for ingredient in ["cucumber", "scallion", "radish", "sauce"]:
		if ingredient in station.required and ingredient not in station.added:
			station._add_ingredient(ingredient)
			return
	station.message = "All required side ingredients are already added."
	station._refresh()


func _set_food_hover(button: Button, active: bool) -> void:
	button.modulate = Color(1.16, 1.08, 0.88, 1.0) if active else Color.WHITE


func _set_food_pressed(button: Button, active: bool) -> void:
	button.modulate = Color(0.82, 0.72, 0.58, 1.0) if active else Color(1.16, 1.08, 0.88, 1.0)


func _set_card_hover(card: Control, active: bool) -> void:
	card.modulate = Color(1.12, 1.06, 0.9, 1.0) if active else Color.WHITE


func _fit_canvas() -> void:
	var factor := minf(station.size.x / DESIGN_SIZE.x, station.size.y / DESIGN_SIZE.y)
	scale = Vector2.ONE * factor
	position = (station.size - DESIGN_SIZE * factor) / 2.0


func _navigate(destination: String) -> void:
	if destination != "cooking":
		station.message = "Station navigation will connect with the team project."
		station.navigation_requested.emit(destination)
	else:
		station.message = "You are at the cooking station."
	update_display()


func update_display() -> void:
	$Game/OrderTicket/OrderTitle.text = "Order %s" % station.order_id
	var required_names: Array[String] = []
	for ingredient in station.required:
		if ingredient != "duck" and station.NAMES.has(ingredient):
			required_names.append(station.NAMES[ingredient])
	$Game/OrderTicket/Recipe.text = " · ".join(required_names)
	for i in range(station.INGREDIENTS.size()):
		var ingredient: String = station.INGREDIENTS[i]
		order_rows[i].text = station.NAMES[ingredient]
		order_checks[i].text = "☑" if ingredient in station.added else "☐"
		order_rows[i].modulate = Color.WHITE if ingredient in station.required else Color(0.58, 0.48, 0.38, 1)
	$Game/PlateFeedback.visible = not station.added.is_empty() or station.rolled
	for label in plate_labels:
		label.text = ""
	if station.rolled:
		plate_labels[0].text = "WRAP ROLLED ✓"
	else:
		for i in range(station.added.size()):
			plate_labels[i].text = "✓ " + station.NAMES[station.added[i]]
	feedback.text = station.message
	gesture_status.text = station.gesture_message
	camera_button.text = "Stop Camera" if station.is_camera_running() else "Start Camera"
	pause_button.text = "▶" if station.paused else "Ⅱ"
	pause_button.tooltip_text = "Resume (Esc)" if station.paused else "Pause (Esc)"
	roll_button.disabled = station.paused or station.completed or station.rolled
	submit_button.disabled = station.paused or station.completed or not station.rolled
	undo_button.disabled = station.paused or station.completed
	for button in ingredient_buttons:
		button.disabled = station.paused or station.completed or station.rolled
	$Gestures/Card1/Status.text = "Completed" if "duck" in station.added else "Waiting"
	var added_sides: int = station.added.size() - (1 if "duck" in station.added else 0)
	$Gestures/Card2/Status.text = "In progress" if added_sides > 0 else "Waiting"
	$Gestures/Card3/Status.text = "Completed" if station.rolled else "Waiting"
