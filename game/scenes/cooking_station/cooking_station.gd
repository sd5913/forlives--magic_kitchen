extends Control

## Standalone cooking prototype. The host may set an order and listen for submission.
signal order_completed(order: Dictionary)

const CookingView = preload("res://scenes/cooking_station/cooking_view.gd")
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
var view


func _ready() -> void:
	_build_interface()
	_refresh()


func _build_interface() -> void:
	view = CookingView.new()
	view.station = self
	add_child(view)


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
	view.update_display()


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
