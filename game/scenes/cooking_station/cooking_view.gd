extends Control

const DESIGN_SIZE := Vector2(1440, 900)
const ACTIVE_BADGE_TINT := Color(1.08, 1.04, 0.86)
const ACTIVE_GESTURE_TINT := Color(1.12, 1.06, 0.82)
const ACTIVE_CARD_TINT := Color(1.08, 1.04, 0.90)

var station
var canvas: Control
var ingredient_buttons: Array[Button] = []
var order_rows: Array[Label] = []
var order_checks: Array[Label] = []
var pause_button: Button
var roll_button: Button
var submit_button: Button
var undo_button: Button
var feedback: Label
var camera_button: Button
var gesture_card_buttons: Array[Button] = []
var side_ingredient_buttons: Dictionary = {}
var queue_order_ids: Array[String] = ["02", "03", "04"]
var queue_buttons: Array[Button] = []


func initialize(owner_station: Control) -> void:
	station = owner_station
	canvas = self
	for ingredient in ["Duck", "Hawthorn", "Cucumber", "Scallion", "Sauce"]:
		var button: Button = get_node("Game/" + ingredient)
		ingredient_buttons.append(button)
		button.pressed.connect(station._add_ingredient.bind(ingredient.to_lower()))
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		order_rows.append(get_node("Game/OrderTicket/" + ingredient))
		var check_path: String = "Game/OrderTicket/" + ingredient + "Check"
		if ingredient == "Duck":
			check_path += "/DuckCheck"
		order_checks.append(get_node(check_path))
	pause_button = $Top/Pause
	roll_button = $Game/Roll
	undo_button = $Game/Undo
	submit_button = $Game/Complete
	feedback = $Game/StatusStrip/Feedback
	camera_button = $Game/StatusStrip/CameraButton
	pause_button.pressed.connect(station._toggle_pause)
	roll_button.pressed.connect(station._roll)
	undo_button.pressed.connect(station._undo)
	submit_button.pressed.connect(station._submit)
	camera_button.pressed.connect(station._restart_camera)
	$Top/Order.pressed.connect(_navigate.bind("order"))
	$Top/Roasting.pressed.connect(_navigate.bind("roasting"))
	$Top/Cooking.pressed.connect(_navigate.bind("cooking"))
	_add_gesture_card_button($Gestures/Card1, station._add_ingredient.bind("duck"), "Simulate one-finger gesture")
	_add_gesture_card_button($Gestures/Card3, station._roll, "Simulate fist gesture")
	for i in range(4):
		var ingredient: String = ["hawthorn", "scallion", "cucumber", "sauce"][i]
		var button := Button.new()
		button.position = Vector2(12 + i * 106, 50)
		button.size = Vector2(100, 94)
		button.flat = true
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.tooltip_text = "Add %s · show %d fingers" % [station.NAMES[ingredient], i + 2]
		button.pressed.connect(station._add_ingredient.bind(ingredient))
		$Gestures/Card2.add_child(button)
		side_ingredient_buttons[ingredient] = button
	for i in range(3):
		var ticket: Control = get_node("Game/Queue" + str(i + 1))
		_prepare_queue_card(ticket)
		var button := Button.new()
		button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		button.flat = true
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_select_order.bind(i))
		ticket.add_child(button)
		queue_buttons.append(button)
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


func _prepare_queue_card(ticket: Control) -> void:
	for child in ticket.get_children():
		if child.name != "Heading" and (child is Label or child is TextureRect):
			child.hide()
	var items := Control.new()
	items.name = "Items"
	items.size = ticket.size
	items.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ticket.add_child(items)
	for row_index in range(5):
		var row := Control.new()
		row.name = "Row" + str(row_index + 1)
		row.position = Vector2(11, 53 + row_index * 24)
		row.size = Vector2(155, 23)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		items.add_child(row)
		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.size = Vector2(22, 22)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
		var label := Label.new()
		label.name = "Text"
		label.position = Vector2(30, 0)
		label.size = Vector2(125, 23)
		label.clip_text = true
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_override("font", ticket.get_node("Heading").get_theme_font("font"))
		label.add_theme_font_size_override("font_size", 15)
		label.add_theme_color_override("font_color", Color(0.23, 0.13, 0.08))
		row.add_child(label)


func _refresh_queue_cards() -> void:
	_reconcile_queue_ids()
	for slot in range(queue_order_ids.size()):
		var ticket: Control = get_node("Game/Queue" + str(slot + 1))
		var order: String = queue_order_ids[slot]
		ticket.get_node("Heading").text = "Order " + order
		queue_buttons[slot].tooltip_text = "Switch to Order " + order
		var row_ids: Array[String] = ["wrap"]
		for ingredient in station.SAMPLE_ORDERS[order]:
			if ingredient != "duck":
				row_ids.append(str(ingredient))
		for row_index in range(5):
			var row: Control = ticket.get_node("Items/Row" + str(row_index + 1))
			row.visible = row_index < row_ids.size()
			if not row.visible:
				continue
			var ingredient: String = row_ids[row_index]
			var icon_path := "Game/OrderTicket/OrderWrapIcon" if ingredient == "wrap" else "Game/OrderTicket/Icon" + ingredient.capitalize()
			var icon: TextureRect = row.get_node("Icon")
			icon.texture = get_node(icon_path).texture
			row.get_node("Text").text = "Wrap × 1" if ingredient == "wrap" else ("Sauce" if ingredient == "sauce" else station.NAMES[ingredient])


func _reconcile_queue_ids() -> void:
	if not station.SAMPLE_ORDERS.has(station.order_id):
		return
	var seen := {station.order_id: true}
	var missing: Array[String] = []
	for id in station.SAMPLE_ORDERS:
		if id != station.order_id and id not in queue_order_ids:
			missing.append(str(id))
	for slot in range(queue_order_ids.size()):
		var id: String = queue_order_ids[slot]
		if seen.has(id):
			queue_order_ids[slot] = missing.pop_front()
		else:
			seen[id] = true


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


func _select_order(slot: int) -> void:
	var target_id: String = queue_order_ids[slot]
	queue_order_ids[slot] = station.order_id
	var ingredients: Array[String] = []
	for ingredient in station.SAMPLE_ORDERS[target_id]:
		ingredients.append(str(ingredient))
	station.switch_order(target_id, ingredients)


func update_display() -> void:
	if queue_buttons.size() == 3:
		_refresh_queue_cards()
	$Game/OrderTicket/OrderTitle.text = "Order %s" % station.order_id
	$Game/OrderTicket/OrderTitle.visible = true
	$Game/OrderTicket/DuckCheck.text = "☑︎" if station.rolled else "☐"
	$Gestures/Card1/Title.text = "Add Sliced Duck"
	$Gestures/Card1/Hint.visible = false
	$Gestures/Card1/Status.position.y = 80
	$Gestures/Card2/Title.text = "Add Other Ingredients"
	$Gestures/Card3/Title.text = "Roll The Wrap"
	$Gestures/Card3/Hint.text = "Make a fist to roll"
	$Gestures/Card3/Status.visible = false
	var required_names: Array[String] = []
	for ingredient in station.required:
		if ingredient != "duck" and station.NAMES.has(ingredient):
			required_names.append(station.NAMES[ingredient])
	$Game/OrderTicket/Recipe.text = " · ".join(required_names)
	var visible_row := 0
	for i in range(station.INGREDIENTS.size()):
		var ingredient: String = station.INGREDIENTS[i]
		var is_required: bool = ingredient in station.required
		order_rows[i].text = station.NAMES[ingredient]
		order_checks[i].text = "☑︎" if ingredient in station.added else "☐"
		order_rows[i].visible = is_required
		order_checks[i].visible = is_required
		var ticket_icon: TextureRect = get_node("Game/OrderTicket/Icon" + ingredient.capitalize())
		ticket_icon.visible = is_required
		if is_required:
			order_rows[i].position.y = 220 + visible_row * 60
			ticket_icon.position.y = 208 + visible_row * 60
			if ingredient != "duck":
				order_checks[i].position.y = 218 + visible_row * 60
			visible_row += 1
	$Game/RolledPlate.visible = station.rolled
	$Game/Plate.visible = not station.rolled
	for ingredient in ["duck", "hawthorn", "scallion", "cucumber", "sauce"]:
		$Game/Fillings.get_node(ingredient.capitalize()).visible = ingredient in station.added and not station.rolled
	var badge_ingredients := ["duck", "hawthorn", "scallion", "cucumber", "sauce"]
	var active_card := 0
	for i in range(badge_ingredients.size()):
		var ingredient: String = badge_ingredients[i]
		var badge: TextureRect = get_node("Game/WorkbenchDecor/NumberBadges/OrderThumbnail" + str(i + 1))
		var gesture_icon: TextureRect = get_node("Gestures/" + ("Card1" if i == 0 else "Card2") + "/Gesture" + str(i + 1))
		var is_active: bool = ingredient == station.highlighted_ingredient and not station.rolled
		if is_active:
			active_card = 1 if i == 0 else 2
		badge.pivot_offset = badge.size / 2.0
		badge.scale = Vector2.ONE * (1.1 if is_active else 1.0)
		badge.self_modulate = ACTIVE_BADGE_TINT if is_active else Color.WHITE
		gesture_icon.self_modulate = ACTIVE_GESTURE_TINT if is_active else Color.WHITE
	var fist_active: bool = station.highlighted_action == "roll_wrap"
	$Gestures/Card1.self_modulate = ACTIVE_CARD_TINT if active_card == 1 else Color.WHITE
	$Gestures/Card2.self_modulate = ACTIVE_CARD_TINT if active_card == 2 else Color.WHITE
	$Gestures/Card3.self_modulate = ACTIVE_CARD_TINT if fist_active else Color.WHITE
	$Gestures/Card3/GestureFist.self_modulate = ACTIVE_GESTURE_TINT if fist_active else Color.WHITE
	feedback.text = "Gesture Status: " + {"waiting": "Waiting for input", "recognized": "Recognized", "unavailable": "Camera unavailable"}[station.gesture_state]
	camera_button.text = "Restart Camera"
	pause_button.text = ""
	pause_button.tooltip_text = "Resume (Esc)" if station.paused else "Pause (Esc)"
	roll_button.disabled = station.paused or station.completed or station.rolled
	submit_button.disabled = station.paused or station.completed or not station.rolled
	undo_button.disabled = station.paused or station.completed
	for button in ingredient_buttons:
		button.disabled = station.paused or station.completed or station.rolled
	$Gestures/Card1/Status.text = "Done" if "duck" in station.added else "Ready  ·  Show 1"
	var added_sides: int = station.added.size() - (1 if "duck" in station.added else 0)
	$Gestures/Card2/Status.text = "In progress" if added_sides > 0 else "Waiting"
	$Gestures/Card3/Status.text = "Done" if station.rolled else "Make a fist to roll"
