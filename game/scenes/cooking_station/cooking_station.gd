extends Control

## Standalone cooking prototype. The host may set an order and listen for submission.
signal order_completed(order: Dictionary)
signal navigation_requested(station_name: String)

const GestureAdapter = preload("res://scenes/cooking_station/gesture_adapter.gd")

const INGREDIENTS := ["duck", "hawthorn", "cucumber", "scallion", "sauce"]
const NAMES := {
	"duck": "Sliced duck", "cucumber": "Cucumber", "scallion": "Scallion",
	"hawthorn": "Hawthorn", "sauce": "Sweet bean sauce"
}
const ACTIONS := {
	"add_duck": "duck", "add_cucumber": "cucumber", "add_scallion": "scallion",
	"add_hawthorn": "hawthorn", "add_sauce": "sauce"
}
const SAMPLE_ORDERS := {
	"01": ["duck", "hawthorn", "cucumber", "scallion", "sauce"],
	"02": ["duck", "cucumber", "sauce"],
	"03": ["duck", "scallion", "hawthorn", "sauce"],
	"04": ["duck", "cucumber", "hawthorn", "sauce"],
}

var order_id := "01"
var required: Array[String] = ["duck", "hawthorn", "cucumber", "scallion", "sauce"]
var added: Array[String] = []
var highlighted_ingredient := ""
var highlighted_action := ""
var rolled := false
var completed := false
var paused := false
var held_actions: Dictionary = {}
var order_progress: Dictionary = {}
var message := ""
var gesture_state := "waiting"
var view
var gesture_adapter
var camera_process_id := -1


func _ready() -> void:
	if get_parent() == get_tree().root:
		get_window().title = "Magic Kitchen - Cooking Station"
	_build_interface()
	gesture_adapter = GestureAdapter.new()
	gesture_adapter.station = self
	add_child(gesture_adapter)
	_refresh()


func _build_interface() -> void:
	view = $Canvas
	view.initialize(self)


func _add_ingredient(ingredient: String) -> void:
	if paused or completed or rolled:
		return
	if not NAMES.has(ingredient):
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
	highlighted_ingredient = ""
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
	get_tree().call_deferred("change_scene_to_file", "res://scenes/cooking_station/rating_placeholder.tscn")


func _toggle_pause() -> void:
	paused = not paused
	held_actions.clear()
	highlighted_ingredient = ""
	highlighted_action = ""
	message = "Paused." if paused else "Ready to continue."
	_refresh()


## Called by a future gesture adapter. It must send false on release/tracking loss.
func receive_action(action: String, active: bool) -> void:
	if not active:
		held_actions.erase(action)
		if held_actions.is_empty() and gesture_state == "recognized":
			gesture_state = "waiting"
		_refresh()
		return
	if paused or held_actions.has(action):
		return
	if not ACTIONS.has(action) and action != "roll_wrap":
		return
	held_actions[action] = true
	gesture_state = "recognized"
	highlighted_ingredient = ACTIONS.get(action, "")
	highlighted_action = action
	if ACTIONS.has(action):
		_add_ingredient(ACTIONS[action])
	elif action == "roll_wrap":
		_roll()


func set_gesture_status(status: String) -> void:
	var normalized := status.to_lower()
	if normalized.contains("unavailable") or normalized.contains("could not") or normalized.contains("missing") or normalized.contains("failed") or normalized.contains("stopped unexpectedly") or normalized.contains("bridge stopped"):
		gesture_state = "unavailable"
	elif normalized.begins_with("camera connected") or normalized.begins_with("waiting for camera bridge") or normalized.begins_with("camera starting"):
		gesture_state = "waiting"
	if gesture_state == "unavailable" or normalized.begins_with("waiting for camera bridge") or normalized.begins_with("camera starting"):
		highlighted_ingredient = ""
		highlighted_action = ""
	if is_node_ready() and view != null:
		view.update_display()


func is_camera_running() -> bool:
	return camera_process_id > 0 and OS.is_process_running(camera_process_id)


func _restart_camera() -> void:
	if is_camera_running():
		OS.kill(camera_process_id)
	camera_process_id = -1
	held_actions.clear()
	set_gesture_status("camera starting")
	var python_path := ProjectSettings.globalize_path("res://../.venv-gesture/Scripts/python.exe")
	var script_path := ProjectSettings.globalize_path("res://../tools/gesture_camera.py")
	if not FileAccess.file_exists(python_path) or not FileAccess.file_exists(script_path):
		set_gesture_status("setup missing - run tools/setup-gesture.ps1")
		return
	camera_process_id = OS.create_process(python_path, PackedStringArray([script_path]))
	if camera_process_id <= 0:
		set_gesture_status("could not start camera")
	else:
		set_gesture_status("camera starting - allow access if prompted")


func _process(_delta: float) -> void:
	if camera_process_id > 0 and not OS.is_process_running(camera_process_id):
		camera_process_id = -1
		held_actions.clear()
		set_gesture_status("camera process stopped unexpectedly")


func _exit_tree() -> void:
	if is_camera_running():
		OS.kill(camera_process_id)


## Minimal handoff for the host scene; caller supplies stable ingredient IDs.
func set_order(id: String, ingredients: Array[String]) -> void:
	order_progress.erase(id)
	order_id = id
	required = ingredients.duplicate()
	added.clear()
	highlighted_ingredient = ""
	highlighted_action = ""
	rolled = false
	completed = false
	held_actions.clear()
	message = ""
	if is_node_ready():
		_refresh()


## Switch the active ticket while keeping each ticket's unfinished wrap.
func switch_order(id: String, ingredients: Array[String]) -> void:
	if id == order_id:
		return
	order_progress[order_id] = {"required": required.duplicate(), "added": added.duplicate(), "rolled": rolled}
	var saved: Dictionary = order_progress.get(id, {})
	order_id = id
	required = ingredients.duplicate()
	if saved.has("required"):
		required.clear()
		for ingredient in saved["required"]:
			required.append(str(ingredient))
	added.clear()
	for ingredient in saved.get("added", []):
		added.append(str(ingredient))
	rolled = bool(saved.get("rolled", false))
	completed = false
	held_actions.clear()
	highlighted_ingredient = ""
	highlighted_action = ""
	message = ""
	_refresh()


func _refresh() -> void:
	view.update_display()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1: _add_ingredient("duck")
		KEY_2: _add_ingredient("hawthorn")
		KEY_3: _add_ingredient("scallion")
		KEY_4: _add_ingredient("cucumber")
		KEY_5: _add_ingredient("sauce")
		KEY_0: _roll()
		KEY_BACKSPACE: _undo()
		KEY_ENTER, KEY_KP_ENTER: _submit()
		KEY_ESCAPE: _toggle_pause()
		KEY_R:
			if not paused:
				set_order(order_id, required)
