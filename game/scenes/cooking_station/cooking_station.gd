extends Control

## Standalone cooking prototype. The host may set an order and listen for submission.
signal order_completed(order: Dictionary)

const FoodArt = preload("res://scenes/cooking_station/food_art.gd")
const ASSETS := "res://assets/ui/cooking_station/"
const INGREDIENTS := ["duck", "cucumber", "scallion", "radish", "sauce"]
const NAMES := {
	"duck": "Sliced duck", "cucumber": "Cucumber", "scallion": "Scallion",
	"radish": "Pickled radish", "sauce": "Sweet bean sauce"
}
const ACTIONS := {
	"add_duck": "duck", "add_cucumber": "cucumber", "add_scallion": "scallion",
	"add_radish": "radish", "add_sauce": "sauce"
}

var order_id := "01"
var required: Array[String] = ["duck", "cucumber", "scallion", "sauce"]
var added: Array[String] = []
var rolled := false
var completed := false
var paused := false
var held_actions: Dictionary = {}
var message := "Choose an ingredient to begin."
var board
var checklist: Label
var feedback: Label
var gesture_status: Label
var progress_label: Label
var roll_button: Button
var submit_button: Button
var pause_button: Button
var ingredient_buttons: Array[Button] = []


func _ready() -> void:
	_build_interface()
	_refresh()


func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = Color("432418")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_rect(Rect2(0, 54, 960, 7), Color("9c5a30"))
	_rect(Rect2(0, 375, 960, 31), Color("653920"))

	_panel(Rect2(12, 7, 201, 45), "navigation_paper_frame.png", 18)
	_label(Rect2(25, 11, 180, 35), "PEKING DUCK  /  COOKING", 15, Color("4c2815"))
	_panel(Rect2(232, 8, 160, 42), "navigation_paper_frame.png", 18)
	_label(Rect2(247, 18, 136, 22), "ORDER STATION", 13, Color("73523a"), HORIZONTAL_ALIGNMENT_CENTER)
	_panel(Rect2(400, 8, 160, 42), "navigation_paper_frame.png", 18)
	_label(Rect2(415, 18, 130, 22), "ROASTING STATION", 13, Color("73523a"), HORIZONTAL_ALIGNMENT_CENTER)
	_panel(Rect2(568, 8, 165, 42), "navigation_selected_frame.png", 18)
	_label(Rect2(575, 18, 151, 22), "COOKING STATION", 13, Color("fff1d2"), HORIZONTAL_ALIGNMENT_CENTER)
	pause_button = _button(Rect2(865, 11, 80, 35), "Pause", _toggle_pause)

	_panel(Rect2(12, 66, 205, 303), "order_main_frame.png", 24)
	_label(Rect2(32, 80, 167, 26), "YOUR ORDER", 14, Color("925329"))
	progress_label = _label(Rect2(32, 105, 170, 49), "", 19, Color("3e2519"))
	_label(Rect2(32, 157, 170, 38), "Peking duck wrap x 1", 14, Color("56351f"))
	checklist = _label(Rect2(32, 201, 170, 132), "", 14, Color("4c2c19"))
	_label(Rect2(32, 337, 168, 22), "Match the customer's order", 11, Color("805739"))

	_panel(Rect2(225, 66, 723, 303), "parchment_panel.png", 24)
	_label(Rect2(246, 78, 260, 25), "PREPARE THE WRAP", 17, Color("542c19"))
	_label(Rect2(651, 81, 268, 21), "Click an ingredient or press 1-5", 12, Color("805739"), HORIZONTAL_ALIGNMENT_RIGHT)
	_rect(Rect2(246, 109, 682, 2), Color("caa775"))
	# Ingredient cards and the central plate use the same component frames.
	_make_ingredient(0, Rect2(249, 123, 135, 102))
	_make_ingredient(1, Rect2(249, 237, 135, 102))
	_make_ingredient(2, Rect2(713, 123, 135, 102))
	_make_ingredient(3, Rect2(713, 237, 135, 102))
	_make_ingredient(4, Rect2(852, 177, 75, 102))
	board = FoodArt.new()
	board.kind = "wrap"
	board.position = Vector2(422, 116)
	board.size = Vector2(253, 235)
	add_child(board)
	_label(Rect2(451, 337, 200, 20), "YOUR WRAP", 12, Color("805739"), HORIZONTAL_ALIGNMENT_CENTER)

	feedback = _label(Rect2(17, 381, 550, 20), "", 13, Color("fff1d6"))
	gesture_status = _label(Rect2(565, 381, 377, 20), "Gesture: camera not connected", 12, Color("f1d9ad"), HORIZONTAL_ALIGNMENT_RIGHT)
	_panel(Rect2(12, 412, 294, 116), "parchment_panel.png", 24)
	_panel(Rect2(314, 412, 330, 116), "parchment_panel.png", 24)
	_panel(Rect2(652, 412, 296, 116), "parchment_panel.png", 24)
	_label(Rect2(27, 424, 270, 22), "1  ADD THE DUCK", 15, Color("4c2916"))
	_label(Rect2(27, 450, 265, 53), "1 finger  /  Key 1\nAdd the sliced duck to the wrap.", 12, Color("6f4c31"))
	_label(Rect2(329, 424, 300, 22), "2  ADD THE INGREDIENTS", 15, Color("4c2916"))
	_label(Rect2(329, 450, 305, 57), "2 cucumber   3 scallion\n4 pickled radish   5 sweet bean sauce", 12, Color("6f4c31"))
	_label(Rect2(667, 424, 265, 22), "3  ROLL & COMPLETE", 15, Color("4c2916"))
	_label(Rect2(667, 448, 264, 18), "Fist / 0 to roll. Enter to submit.", 11, Color("6f4c31"))
	roll_button = _button(Rect2(666, 476, 75, 34), "Roll", _roll)
	_button(Rect2(745, 476, 75, 34), "Undo", _undo)
	submit_button = _button(Rect2(824, 476, 108, 34), "Complete", _submit)


func _make_ingredient(index: int, rect: Rect2) -> void:
	var ingredient: String = INGREDIENTS[index]
	var button := _button(rect, "", _add_ingredient.bind(ingredient))
	ingredient_buttons.append(button)
	var art = FoodArt.new()
	art.kind = ingredient
	art.position = rect.position + Vector2(10, 8)
	art.size = Vector2(rect.size.x - 20, 60)
	add_child(art)
	_label(Rect2(rect.position.x + 2, rect.position.y + 73, rect.size.x - 4, 23),
		"%d  %s" % [index + 1, NAMES[ingredient] if ingredient != "sauce" else "Sauce"], 11,
		Color("4c2916"), HORIZONTAL_ALIGNMENT_CENTER)


func _rect(rect: Rect2, color: Color) -> void:
	var box := ColorRect.new()
	box.position = rect.position
	box.size = rect.size
	box.color = color
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)


func _panel(rect: Rect2, filename: String, margin: int) -> void:
	var panel := NinePatchRect.new()
	panel.texture = load(ASSETS + filename)
	panel.position = rect.position
	panel.size = rect.size
	panel.patch_margin_left = margin
	panel.patch_margin_top = margin
	panel.patch_margin_right = margin
	panel.patch_margin_bottom = margin
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)


func _label(rect: Rect2, value: String, font_size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = value
	label.horizontal_alignment = alignment
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label


func _button(rect: Rect2, value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.text = value
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color("4c2916"))
	button.add_theme_color_override("font_hover_color", Color("723817"))
	button.add_theme_color_override("font_disabled_color", Color("a7937a"))
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxTexture.new()
		style.texture = load(ASSETS + "inset_panel.png")
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			style.set_texture_margin(side, 10)
		if state == "hover":
			style.modulate_color = Color("ffe6ae")
		elif state == "pressed":
			style.modulate_color = Color("d7ad76")
		elif state == "disabled":
			style.modulate_color = Color("b8a99a")
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(callback)
	add_child(button)
	return button


func _add_ingredient(ingredient: String) -> void:
	if paused or completed or rolled:
		return
	if ingredient in added:
		message = "%s is already on the wrap." % NAMES[ingredient]
	else:
		added.append(ingredient)
		message = "Added %s.%s" % [NAMES[ingredient], " This is not in the order; use Undo." if ingredient not in required else ""]
	_refresh()


func _roll() -> void:
	if paused or completed or rolled:
		return
	for ingredient in required:
		if ingredient not in added:
			message = "Still needed: %s." % NAMES[ingredient]
			_refresh()
			return
	for ingredient in added:
		if ingredient not in required:
			message = "%s is not in this order. Use Undo." % NAMES[ingredient]
			_refresh()
			return
	rolled = true
	message = "Wrap rolled! Complete the order when ready."
	_refresh()


func _undo() -> void:
	if paused or completed:
		return
	if rolled:
		rolled = false
		message = "Wrap opened again."
	elif not added.is_empty():
		var removed: String = added.pop_back()
		message = "Removed %s." % NAMES[removed]
	else:
		message = "There is nothing to undo."
	_refresh()


func _submit() -> void:
	if paused or completed:
		return
	if not rolled:
		message = "Roll the completed wrap before submitting."
		_refresh()
		return
	completed = true
	message = "Order %s complete! Press R to try again." % order_id
	order_completed.emit({"order_id": order_id, "ingredients": added.duplicate(), "rolled": true})
	_refresh()


func _toggle_pause() -> void:
	paused = not paused
	held_actions.clear()
	message = "Paused." if paused else "Ready to continue."
	_refresh()


## Called by a future gesture adapter. It must send false on release/tracking loss.
func receive_action(action: String, active: bool) -> void:
	if not active:
		held_actions.erase(action)
		return
	if paused or held_actions.has(action):
		return
	held_actions[action] = true
	if ACTIONS.has(action):
		_add_ingredient(ACTIONS[action])
	elif action == "roll_wrap":
		_roll()


## Minimal handoff for the host scene; caller supplies stable ingredient IDs.
func set_order(id: String, ingredients: Array[String]) -> void:
	order_id = id
	required = ingredients.duplicate()
	added.clear()
	rolled = false
	completed = false
	held_actions.clear()
	message = "Choose an ingredient to begin."
	if is_node_ready():
		_refresh()


func _refresh() -> void:
	progress_label.text = "ORDER %s" % order_id
	var lines: Array[String] = []
	for ingredient in INGREDIENTS:
		if ingredient in required:
			lines.append("%s  %s" % ["[x]" if ingredient in added else "[  ]", NAMES[ingredient]])
	checklist.text = "\n".join(lines)
	feedback.text = message
	board.ingredients = added.duplicate()
	board.rolled = rolled
	board.queue_redraw()
	roll_button.disabled = paused or completed or rolled
	submit_button.disabled = paused or completed or not rolled
	pause_button.text = "Resume" if paused else "Pause"
	for button in ingredient_buttons:
		button.disabled = paused or completed or rolled


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1: _add_ingredient("duck")
		KEY_2: _add_ingredient("cucumber")
		KEY_3: _add_ingredient("scallion")
		KEY_4: _add_ingredient("radish")
		KEY_5: _add_ingredient("sauce")
		KEY_0: _roll()
		KEY_BACKSPACE: _undo()
		KEY_ENTER, KEY_KP_ENTER: _submit()
		KEY_ESCAPE: _toggle_pause()
		KEY_R:
			if not paused:
				set_order(order_id, required)
