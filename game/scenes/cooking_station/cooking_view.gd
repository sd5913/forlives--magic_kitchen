extends Control

const ASSETS := "res://assets/ui/cooking_station/"
const DESIGN_SIZE := Vector2(1536, 1024)
const INK := Color("3b2116")

var station
var canvas: Control
var order_title: Label
var recipe: Label
var order_rows: Array[Label] = []
var order_checks: Array[Label] = []
var feedback: Label
var gesture_status: Label
var pause_button: Button
var roll_button: Button
var submit_button: Button
var undo_button: Button
var ingredient_buttons: Array[Button] = []
var plate_labels: Array[Label] = []
var plate_back: ColorRect
var font: SystemFont


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var surround := ColorRect.new()
	surround.color = Color("23130d")
	surround.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	surround.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(surround)
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Georgia", "Times New Roman", "Liberation Serif", "serif"])
	font.font_weight = 700
	canvas = Control.new()
	canvas.size = DESIGN_SIZE
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	_build()
	resized.connect(_fit_canvas)
	_fit_canvas()


func _fit_canvas() -> void:
	var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - DESIGN_SIZE * factor) / 2.0


func _build() -> void:
	# The selected Figma reference supplies the kitchen environment and food art.
	var background := TextureRect.new()
	background.texture = load(ASSETS + "cooking_reference.png")
	background.size = DESIGN_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(background)

	# Shared Figma navigation frames replace the reference's flattened controls.
	_panel(Rect2(363, 8, 245, 72), "navigation_paper_frame.png", 18)
	_panel(Rect2(634, 8, 245, 72), "navigation_paper_frame.png", 18)
	_panel(Rect2(909, 8, 249, 72), "navigation_selected_frame.png", 18)
	_label(Rect2(375, 23, 220, 38), "Order Station", 25, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_label(Rect2(646, 23, 220, 38), "Roasting Station", 25, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_label(Rect2(921, 23, 225, 38), "Cooking Station", 25, Color("fff0d6"), HORIZONTAL_ALIGNMENT_CENTER)
	pause_button = _hit_button(Rect2(1450, 14, 72, 62), station._toggle_pause)
	pause_button.tooltip_text = "Pause / resume (Esc)"

	# Main ticket is real content, not the order baked into the reference image.
	_panel(Rect2(8, 160, 315, 545), "order_main_frame.png", 24)
	order_title = _label(Rect2(30, 182, 270, 39), "", 29, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_label(Rect2(31, 236, 270, 28), "Peking Duck Wrap  x 1", 21, INK)
	recipe = _label(Rect2(31, 269, 270, 75), "", 19, INK)
	for i in range(5):
		_crop(Rect2(27, 350 + i * 67, 70, 55), Rect2(28, 350 + i * 67, 70, 55))
		var row := _label(Rect2(103, 365 + i * 67, 170, 35), "", 18, INK)
		order_rows.append(row)
		order_checks.append(_label(Rect2(277, 362 + i * 67, 30, 32), "", 23, INK))

	# These are empty queue slots until the host supplies multiple orders.
	for i in range(3):
		var x := 336.0 + i * 185.0
		_panel(Rect2(x, 165, 168, 179), "order_mini_frame.png", 14)
		_label(Rect2(x + 15, 184, 138, 28), "NEXT ORDER", 18, INK, HORIZONTAL_ALIGNMENT_CENTER)
		_label(Rect2(x + 17, 230, 134, 57), "Waiting for\nnext customer", 15, Color("805c3e"), HORIZONTAL_ALIGNMENT_CENTER)

	var zones := [Rect2(386, 426, 320, 220), Rect2(727, 408, 178, 112),
		Rect2(1205, 407, 180, 112), Rect2(724, 540, 181, 113), Rect2(1224, 540, 196, 113)]
	for i in range(zones.size()):
		var ingredient: String = station.INGREDIENTS[i]
		var button := _hit_button(zones[i], station._add_ingredient.bind(ingredient))
		button.tooltip_text = "%s (%d)" % [station.NAMES[ingredient], i + 1]
		ingredient_buttons.append(button)

	# Small, readable status tags appear on the pancake as ingredients are added.
	plate_back = ColorRect.new()
	plate_back.position = Vector2(967, 468)
	plate_back.size = Vector2(174, 117)
	plate_back.color = Color(0.95, 0.86, 0.66, 0.92)
	plate_back.visible = false
	plate_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(plate_back)
	for i in range(5):
		plate_labels.append(_label(Rect2(978, 472 + i * 20, 155, 22), "", 16, INK))

	# Replace the flattened complete button and status with functioning controls.
	submit_button = _paper_button(Rect2(1271, 686, 240, 62), "Complete Order", station._submit, 24)
	_rect(Rect2(12, 734, 1165, 41), Color("512b19"))
	feedback = _label(Rect2(26, 740, 700, 28), "", 19, Color("fff0d4"))
	gesture_status = _label(Rect2(730, 741, 437, 26), "Camera not connected", 18, Color("f2d8ad"), HORIZONTAL_ALIGNMENT_RIGHT)
	roll_button = _paper_button(Rect2(1002, 689, 110, 37), "Roll [0]", station._roll, 16)
	undo_button = _paper_button(Rect2(1124, 689, 110, 37), "Undo", station._undo, 16)

	# Shared parchment panels and cropped reference illustrations for the guide.
	_panel(Rect2(16, 790, 482, 212), "parchment_panel.png", 24)
	_panel(Rect2(510, 790, 520, 212), "parchment_panel.png", 24)
	_panel(Rect2(1041, 790, 480, 212), "parchment_panel.png", 24)
	_label(Rect2(40, 801, 400, 31), "Gesture Operation", 25, INK)
	_crop(Rect2(53, 836, 126, 135), Rect2(52, 836, 126, 135))
	_label(Rect2(190, 855, 285, 36), "1. Pick up sliced duck", 23, INK)
	_label(Rect2(191, 899, 272, 64), "One finger adds the duck\nto the wrapper.", 18, INK)
	_label(Rect2(548, 801, 420, 33), "2. Add ingredients", 25, INK)
	_label(Rect2(558, 836, 440, 25), "Show 2–5 fingers to add ingredients.", 18, INK)
	for i in range(4):
		_crop(Rect2(551 + i * 116, 865, 82, 90), Rect2(550 + i * 116, 865, 82, 90))
	var names := ["Cucumber", "Scallion", "Radish", "Sauce"]
	for i in range(4):
		_label(Rect2(531 + i * 116, 959, 120, 25), names[i], 17, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_crop(Rect2(1066, 835, 126, 135), Rect2(1065, 835, 126, 135))
	_label(Rect2(1205, 852, 280, 35), "3. Roll the wrap", 23, INK)
	_label(Rect2(1207, 898, 270, 66), "Make a fist to roll.\nThen complete the order.", 18, INK)


func update_display() -> void:
	order_title.text = "Order %s" % station.order_id
	var required_names: Array[String] = []
	for ingredient in station.required:
		if ingredient != "duck" and station.NAMES.has(ingredient):
			required_names.append(station.NAMES[ingredient])
	recipe.text = " · ".join(required_names)
	for i in range(station.INGREDIENTS.size()):
		var ingredient: String = station.INGREDIENTS[i]
		var mark := "☑" if ingredient in station.added else "☐"
		order_rows[i].text = station.NAMES[ingredient]
		order_checks[i].text = mark
		order_rows[i].modulate = Color.WHITE if ingredient in station.required else Color(0.58, 0.48, 0.38, 1)
	plate_back.visible = not station.added.is_empty() or station.rolled
	for i in range(plate_labels.size()):
		plate_labels[i].text = ""
	if station.rolled:
		plate_labels[0].text = "WRAP ROLLED ✓"
	else:
		for i in range(station.added.size()):
			plate_labels[i].text = "✓ " + station.NAMES[station.added[i]]
	feedback.text = station.message
	gesture_status.text = "Gesture: camera not connected"
	pause_button.tooltip_text = "Resume (Esc)" if station.paused else "Pause (Esc)"
	roll_button.disabled = station.paused or station.completed or station.rolled
	submit_button.disabled = station.paused or station.completed or not station.rolled
	undo_button.disabled = station.paused or station.completed
	for button in ingredient_buttons:
		button.disabled = station.paused or station.completed or station.rolled


func _panel(rect: Rect2, image_name: String, margin: int) -> void:
	var panel := NinePatchRect.new()
	panel.texture = load(ASSETS + image_name)
	panel.position = rect.position
	panel.size = rect.size
	panel.patch_margin_left = margin
	panel.patch_margin_top = margin
	panel.patch_margin_right = margin
	panel.patch_margin_bottom = margin
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(panel)


func _crop(source: Rect2, destination: Rect2) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(ASSETS + "cooking_reference.png")
	atlas.region = source
	var sprite := TextureRect.new()
	sprite.texture = atlas
	sprite.position = destination.position
	sprite.size = destination.size
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_SCALE
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(sprite)


func _rect(rect: Rect2, color: Color) -> void:
	var fill := ColorRect.new()
	fill.position = rect.position
	fill.size = rect.size
	fill.color = color
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(fill)


func _label(rect: Rect2, value: String, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = value
	label.horizontal_alignment = align
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	canvas.add_child(label)
	return label


func _hit_button(rect: Rect2, callback: Callable) -> Button:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.focus_mode = Control.FOCUS_ALL
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("disabled", empty)
	button.add_theme_stylebox_override("focus", empty)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1, 0.85, 0.55, 0.16)
	hover.set_corner_radius_all(12)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.pressed.connect(callback)
	canvas.add_child(button)
	return button


func _paper_button(rect: Rect2, text_value: String, callback: Callable, font_size: int) -> Button:
	var button := _hit_button(rect, callback)
	button.flat = false
	button.text = text_value
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_disabled_color", Color("a98c70"))
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxTexture.new()
		style.texture = load(ASSETS + "navigation_paper_frame.png")
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			style.set_texture_margin(side, 18)
		if state == "hover":
			style.modulate_color = Color("ffe5ab")
		elif state == "disabled":
			style.modulate_color = Color("bcaa95")
		button.add_theme_stylebox_override(state, style)
	return button
