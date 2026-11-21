extends SceneTree

const Station = preload("res://scenes/cooking_station/cooking_station.tscn")
var failures := 0
var submissions: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
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
	station.queue_free()
	print("Cooking station checks: %d failure(s)" % failures)
	quit(1 if failures else 0)


func _check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error("FAILED: " + description)
