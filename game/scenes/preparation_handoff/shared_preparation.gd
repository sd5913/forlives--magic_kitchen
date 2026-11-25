extends Control
## Presentation adapter for the contributor's scene; the shared session owns all rules.
const INGREDIENTS := ["duck", "hawthorn", "cucumber", "scallion", "sauce"]
const NAMES := {"duck": "Sliced Duck", "hawthorn": "Hawthorn Strips", "cucumber": "Cucumber Strips", "scallion": "Scallion Strips", "sauce": "Sweet Bean Sauce"}
const TO_SHARED := {"duck": "duck_meat", "hawthorn": "hawthorn", "cucumber": "cucumber", "scallion": "scallion", "sauce": "sweet_sauce"}
const INPUT_ORDER := ["duck", "hawthorn", "scallion", "cucumber", "sauce"]
var host: Control
var session: Node
var view: Control
var order_id := ""
var required: Array[String] = []
var added: Array[String] = []
var rolled := false
var completed := false
var paused := false
var highlighted_ingredient := ""
var highlighted_action := ""
var gesture_state := "waiting"
var queue_ids: Array[String] = []
var _patience: Label
var correction_buttons: Dictionary = {}


func initialize(shared_host: Control) -> void:
	host = shared_host
	session = host.session
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = Vector2(1440, 900)
	view = $Canvas
	read_session()
	view.initialize(self)
	view.feedback.clip_text = true
	view.feedback.size.x = 1120
	view.camera_button.position = Vector2(1220, 7)
	for index in range(INGREDIENTS.size()):
		var ingredient: String = INGREDIENTS[index]
		if ingredient == "duck":
			continue
		var correction := Button.new()
		correction.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		correction.flat = true
		correction.tooltip_text = "Remove " + NAMES[ingredient]
		correction.pressed.connect(func(): _remove_ingredient(TO_SHARED[ingredient]))
		view.order_rows[index].add_child(correction)
		correction_buttons[ingredient] = correction
	_patience = Label.new()
	_patience.position = Vector2(27, 502)
	_patience.size = Vector2(290, 32)
	_patience.add_theme_font_override("font", host._font)
	_patience.add_theme_font_size_override("font_size", 16)
	_patience.add_theme_color_override("font_color", Color("542c14"))
	view.get_node("Game/OrderTicket").add_child(_patience)
	view.update_display()
	refresh_times()


func read_session() -> void:
	order_id = session.manager.selected_order_id
	var order: Dictionary = session.manager.get_order(order_id)
	var food: Dictionary = session.current_food()
	required.clear()
	added.clear()
	for local_id in INGREDIENTS:
		for item in order.get("ingredients", []):
			if item.id == TO_SHARED[local_id]:
				required.append(local_id)
		if TO_SHARED[local_id] in food.get("ingredients", []):
			added.append(local_id)
	rolled = food.get("stage") == "ready"
	completed = food.get("stage") != "preparing"
	paused = session.paused
	highlighted_ingredient = INPUT_ORDER[host.preparation_highlight - 1] if host.preparation_highlight > 0 else ""
	highlighted_action = "roll_wrap" if host.preparation_highlight == 0 else ""
	gesture_state = "unavailable" if host.receiver.status.to_lower().contains("unavailable") else ("recognized" if host.preparation_highlight >= 0 else "waiting")


func _add_ingredient(ingredient: String) -> void:
	var index := INPUT_ORDER.find(ingredient)
	if index >= 0:
		host._perform_action(index + 1)


func _roll() -> void:
	host._perform_action(0)


func _undo() -> void:
	var food: Dictionary = session.current_food()
	var ingredients: Array = food.get("ingredients", [])
	for index in range(ingredients.size() - 1, -1, -1):
		if ingredients[index] != "duck_meat":
			_remove_ingredient(ingredients[index])
			return


func _remove_ingredient(shared_id: String) -> void:
	if session.remove_ingredient(shared_id):
		host.preparation_highlight = -1


func _submit() -> void:
	session.serve_current()


func _toggle_pause() -> void:
	host._pause()


func _restart_camera() -> void:
	host.receiver.toggle_camera()


func navigate(destination: String) -> void:
	var shared: String = {"order": "order", "roasting": "roast", "cooking": "prepare"}.get(destination, "prepare")
	host._navigate(shared)


func select_queue_order(slot: int) -> void:
	if slot < queue_ids.size():
		host._select(queue_ids[slot])


func refresh_queue_cards() -> void:
	queue_ids.clear()
	for order in session.manager.get_visible_orders():
		if order.order_id != order_id:
			queue_ids.append(str(order.order_id))
	for slot in range(3):
		var ticket: Control = view.get_node("Game/Queue" + str(slot + 1))
		var has_order := slot < queue_ids.size()
		view.queue_buttons[slot].disabled = not has_order or not session.can_interact()
		ticket.get_node("Heading").text = queue_ids[slot] if has_order else "No waiting order"
		var items: Array = []
		if has_order:
			items = session.manager.get_order(queue_ids[slot]).ingredients
		for row_index in range(5):
			var row: Control = ticket.get_node("Items/Row" + str(row_index + 1))
			row.visible = row_index < items.size()
			if not row.visible:
				continue
			var ingredient: String = items[row_index].id
			var local_id := local_id_for(ingredient)
			var icon_path := "Game/OrderTicket/OrderWrapIcon" if ingredient == "wrapper" else "Game/OrderTicket/Icon" + local_id.capitalize()
			row.get_node("Icon").texture = view.get_node(icon_path).texture
			row.get_node("Text").text = "Wrap × 1" if ingredient == "wrapper" else NAMES.get(local_id, ingredient)


func local_id_for(shared_id: String) -> String:
	for local_id in TO_SHARED:
		if TO_SHARED[local_id] == shared_id:
			return local_id
	return ""


func apply_shared_controls() -> void:
	for index in range(INGREDIENTS.size()):
		var number := INPUT_ORDER.find(INGREDIENTS[index]) + 1
		view.ingredient_buttons[index].disabled = not session.action_available(number) or host._popup_open()
	var row_index := 0
	var visible_rows := 0
	for ingredient in INGREDIENTS:
		if ingredient in required or ingredient in added:
			visible_rows += 1
	var row_step := 55 if visible_rows == 5 else 60
	for index in range(INGREDIENTS.size()):
		var ingredient: String = INGREDIENTS[index]
		var show_row := ingredient in required or ingredient in added
		var icon: TextureRect = view.get_node("Game/OrderTicket/Icon" + ingredient.capitalize())
		view.order_rows[index].visible = show_row
		view.order_checks[index].visible = show_row
		icon.visible = show_row
		if show_row:
			view.order_rows[index].position.y = 220 + row_index * row_step
			view.order_rows[index].text = NAMES[ingredient].replace(" Strips", "\nStrips")
			icon.position.y = 208 + row_index * row_step
			if ingredient != "duck":
				view.order_checks[index].position.y = 218 + row_index * row_step
			view.order_rows[index].self_modulate = Color("9f2816") if ingredient not in required else Color.WHITE
			row_index += 1
		if correction_buttons.has(ingredient):
			correction_buttons[ingredient].disabled = not session.can_interact() or session.current_food().get("stage") != "preparing" or ingredient not in added
	view.roll_button.disabled = not session.action_available(0) or host._popup_open()
	view.submit_button.disabled = not session.can_interact() or session.current_food().get("stage") != "ready"
	var can_correct: bool = session.can_interact() and session.current_food().get("stage") == "preparing"
	view.undo_button.disabled = not can_correct or added.size() <= (1 if "duck" in added else 0)
	for local_id in view.side_ingredient_buttons:
		view.side_ingredient_buttons[local_id].disabled = not session.action_available(INPUT_ORDER.find(local_id) + 1)
	for index in range(view.gesture_card_buttons.size()):
		view.gesture_card_buttons[index].disabled = not session.action_available(1 if index == 0 else 0)
	var stage: String = session.current_food().get("stage", "waiting")
	var status: String = "Paused · press Esc to resume" if paused else ("Waiting for accepted, sliced duck" if stage == "waiting" or stage.is_empty() else session.message)
	if stage == "ready" and not paused:
		status = "Wrap ready · complete this order"
	view.feedback.text = status
	view.camera_button.text = "Stop Camera" if host.receiver.camera_pid > 0 else "Start Camera"
	view.camera_button.tooltip_text = host.receiver.status
	view.get_node("Top/Pause").tooltip_text = "Resume (Esc)" if paused else "Pause (Esc)"
	view.get_node("Gestures/Card1/Status").text = "Done" if "duck" in added else ("Ready · Show 1" if session.action_available(1) else "Roast and slice first")
	view.get_node("Gestures/Card3/Hint").visible = false
	view.get_node("Gestures/Card3/Status").visible = true
	view.get_node("Gestures/Card3/Status").text = "Ready to serve" if rolled else ("Rolling…" if stage == "wrapping" else "Make a fist to roll")


func refresh_times() -> void:
	if not is_instance_valid(_patience):
		return
	var order: Dictionary = session.manager.get_order(order_id)
	_patience.text = "Patience %ds · %s" % [ceili(order.get("remaining_seconds", 0)), str(order.get("status", "no order"))]
