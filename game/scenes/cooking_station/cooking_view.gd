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
	for ingredient in ["Duck", "Hawthorn", "Cucumber", "Scallion", "Sauce"]:
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
	gesture_status.position = Vector2(822, 9)
	gesture_status.size = Vector2(186, 30)
	camera_button.position = Vector2(1016, 9)
	camera_button.size = Vector2(166, 31)
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
	for i in range(3):
		var ticket: Control = get_node("Game/Queue" + str(i + 1))
		var button := Button.new()
		button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		button.flat = true
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.tooltip_text = "Select Order %02d" % (i + 2)
		button.pressed.connect(_select_order.bind(i + 2))
		ticket.add_child(button)
	station.resized.connect(_fit_canvas)
	_fit_canvas()


func _normalize_art() -> void:
	# Several Figma exports are opaque light gray. Remove that matte from icons,
	# and use the transparent originals wherever the art folder provides them.
	$Game/OrderHanger.texture = load("res://assets/ui/Cooking_station new/OrderHanger.png")
	$Game/OrderTicket.texture = load("res://assets/ui/cooking_station/order_main_frame.png")
	for ticket_path in ["Game/Queue1", "Game/Queue2", "Game/Queue3"]:
		get_node(ticket_path).texture = load("res://assets/ui/cooking_station/order_mini_frame.png")
	for heading_path in ["Game/Queue1/Heading", "Game/Queue2/Heading", "Game/Queue3/Heading"]:
		get_node(heading_path).visible = true
	$Game/Queue2/BlankHeader.visible = false
	$Gestures/Card1.texture = load("res://assets/ui/Cooking_station new/figma_gesture_card_left.png")
	$Gestures/Card2.texture = load("res://assets/ui/Cooking_station new/figma_gesture_card_middle.png")
	$Gestures/Card3.texture = load("res://assets/ui/Cooking_station new/figma_gesture_card_right.png")
	for icon_path in ["Gestures/Card1/Icon", "Gestures/Card2/Side1", "Gestures/Card2/Side2", "Gestures/Card2/Side3", "Gestures/Card2/Side4", "Gestures/Card3/Icon"]:
		get_node(icon_path).visible = true
	var matte_shader := Shader.new()
	matte_shader.code = """shader_type canvas_item;
void fragment() {
 vec4 c = texture(TEXTURE, UV);
 vec3 matte_gray = vec3(245.0 / 255.0);
 vec3 matte_white = vec3(1.0);
 float gray_distance = length(c.rgb - matte_gray);
 float white_distance = length(c.rgb - matte_white);
 vec3 matte = gray_distance < white_distance ? matte_gray : matte_white;
 float alpha = smoothstep(0.025, 0.14, min(gray_distance, white_distance));
 c.rgb = clamp((c.rgb - matte * (1.0 - alpha)) / max(alpha, 0.001), vec3(0.0), vec3(1.0));
 c.a *= alpha;
 COLOR = c;
}"""
	var matte_material := ShaderMaterial.new()
	matte_material.shader = matte_shader
	for icon_path in ["Game/OrderTicket/IconDuck", "Game/OrderTicket/IconHawthorn", "Game/OrderTicket/IconCucumber", "Game/OrderTicket/IconScallion", "Game/OrderTicket/IconSauce", "Game/StatusStrip/GestureStatusIcon", "Gestures/Card1/Icon", "Gestures/Card2/Side1", "Gestures/Card2/Side2", "Gestures/Card2/Side3", "Gestures/Card2/Side4", "Gestures/Card3/Icon", "Game/RolledPlate"]:
		get_node(icon_path).material = matte_material
	var crops := {
		"Game/Hawthorn/Art": Rect2(620, 368, 197, 116),
		"Game/Cucumber/Art": Rect2(620, 490, 197, 130),
		"Game/Scallion/Art": Rect2(1084, 368, 201, 119),
		"Game/Sauce/Art": Rect2(1085, 487, 221, 133),
		"Game/Plate": Rect2(818, 390, 265, 215),
	}
	for art_path in crops:
		var art: TextureRect = get_node(art_path)
		var crop: AtlasTexture = art.texture
		crop.region = crops[art_path]
	# The source sheet's dishes touch each other. Drawing them as separate atlas
	# rectangles exposes neighboring white pixels at their rectangular edges.
	# Keep separate invisible buttons for interaction, but draw the intact sheet.
	var food_display := TextureRect.new()
	food_display.name = "FoodDisplay"
	food_display.texture = load("res://assets/ui/Cooking_station new/SlicedDuckand four mateerials in the middle area.png")
	food_display.position = Vector2(45, -90)
	food_display.size = Vector2(1405, 841)
	food_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	food_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Game.add_child(food_display)
	$Game.move_child(food_display, $Game/Duck.get_index())
	for art_path in ["Game/Duck/Art", "Game/Hawthorn/Art", "Game/Cucumber/Art", "Game/Scallion/Art", "Game/Sauce/Art", "Game/Plate"]:
		get_node(art_path).visible = false
	_add_food_overlay("Badge2", "Order Thumbnail-2", Vector2(651, 268), Vector2(49, 49))
	_add_food_overlay("Badge3", "Order Thumbnail-3", Vector2(1098, 267), Vector2(49, 49))
	_add_food_overlay("Badge4", "Order Thumbnail-4", Vector2(651, 398), Vector2(49, 49))
	_add_food_overlay("Badge5", "Order Thumbnail-5", Vector2(1101, 397), Vector2(49, 49))
	_add_food_overlay("DuckNameplate", "Board1_", Vector2(409, 477), Vector2(180, 54))
	_add_food_overlay("HawthornNameplate", "Board2_", Vector2(697, 341), Vector2(128, 44))
	_add_food_overlay("CucumberNameplate", "Board4_", Vector2(699, 473), Vector2(128, 44))
	_add_food_overlay("SauceNameplate", "Board5_", Vector2(1157, 474), Vector2(135, 45))
	if _find_food_asset("Board3_") != null:
		_add_food_overlay("ScallionNameplate", "Board3_", Vector2(1154, 343), Vector2(135, 45))
	else:
		var scallion_label := Label.new()
		scallion_label.name = "ScallionNameplate"
		scallion_label.position = Vector2(1154, 354)
		scallion_label.size = Vector2(135, 28)
		scallion_label.text = "Scallion Strips"
		scallion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scallion_label.add_theme_color_override("font_color", Color("331805"))
		scallion_label.add_theme_font_size_override("font_size", 16)
		scallion_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Game.add_child(scallion_label)


func _find_food_asset(prefix: String) -> Texture2D:
	var folder := "res://assets/ui/Cooking_station new/"
	for filename in DirAccess.get_files_at(folder):
		if filename.begins_with(prefix) and filename.ends_with(".png"):
			return load(folder + filename)
	return null


func _add_food_overlay(node_name: String, asset_prefix: String, point: Vector2, dimensions: Vector2) -> void:
	var image := _find_food_asset(asset_prefix)
	if image == null:
		return
	var overlay := TextureRect.new()
	overlay.name = node_name
	overlay.texture = image
	overlay.position = point
	overlay.size = dimensions
	overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay.stretch_mode = TextureRect.STRETCH_SCALE
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Game.add_child(overlay)


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
	for ingredient in ["hawthorn", "scallion", "cucumber", "sauce"]:
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


func _select_order(index: int) -> void:
	var recipes := {
		2: ["duck", "cucumber", "sauce"],
		3: ["duck", "scallion", "hawthorn", "sauce"],
		4: ["duck", "cucumber", "hawthorn", "sauce"],
	}
	var ingredients: Array[String] = []
	for ingredient in recipes[index]:
		ingredients.append(ingredient)
	station.set_order("%02d" % index, ingredients)


func update_display() -> void:
	$Game/OrderTicket/OrderTitle.text = "Order %s" % station.order_id
	$Game/OrderTicket/OrderTitle.visible = true
	$Gestures/Card1/Title.text = "1 · Add Sliced Duck"
	$Gestures/Card1/Hint.visible = false
	$Gestures/Card1/Status.position.y = 80
	$Gestures/Card2/Title.text = "2 · Add Other Ingredients"
	$Gestures/Card3/Title.text = "3 · Roll The Wrap"
	$Gestures/Card3/Hint.text = "Make a fist to roll"
	$Gestures/Card3/Status.visible = false
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
	$Game/PlateFeedback.visible = not station.added.is_empty() and not station.rolled
	$Game/RolledPlate.visible = station.rolled
	$Game/Plate.visible = false
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
	pause_button.text = ""
	pause_button.tooltip_text = "Resume (Esc)" if station.paused else "Pause (Esc)"
	roll_button.disabled = station.paused or station.completed or station.rolled
	submit_button.disabled = station.paused or station.completed
	undo_button.disabled = station.paused or station.completed
	for button in ingredient_buttons:
		button.disabled = station.paused or station.completed or station.rolled
	$Gestures/Card1/Status.text = "Done" if "duck" in station.added else "Ready  ·  Show 1"
	var added_sides: int = station.added.size() - (1 if "duck" in station.added else 0)
	$Gestures/Card2/Status.text = "In progress" if added_sides > 0 else "Waiting"
	$Gestures/Card3/Status.text = "Done" if station.rolled else "Make a fist to roll"
