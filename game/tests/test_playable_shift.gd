extends SceneTree

const Workbench = preload("res://scenes/workbench.tscn")
var _failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var workbench = Workbench.instantiate()
	root.add_child(workbench)
	workbench.set_process(false)
	var panel = workbench.get_node("OrderPanel")
	panel.get_node("OpenOrders").pressed.emit()
	var station = panel._station
	var manager = workbench.manager
	_check(station.manager == manager, "order station uses the host manager")
	var id: String = manager.selected_order_id
	station._accept_current()
	station._open_workbench("roast")
	_check(not station.visible, "roast returns to workbench")
	workbench._roast_button.pressed.emit()
	_check(manager.get_order(id)["status"] == "roasting", "start roast for same ticket")
	var before: float = manager.elapsed_seconds
	workbench._process(4.0)
	_check(is_equal_approx(manager.elapsed_seconds, before + 4.0), "one shared clock advances outside order station")
	_check(manager.get_order(id)["status"] == "preparing", "roast completes for same ticket")
	workbench._prep_button.pressed.emit()
	_check(manager.get_order(id)["status"] == "preparing", "wrong ingredients do not complete roll")
	var order: Dictionary = manager.get_order(id)
	for item in order["ingredients"]:
		if item["id"] == "duck_meat":
			continue
		workbench._ingredient_picker.select(workbench._ingredient_ids.find(item["id"]))
		for count in range(int(item["quantity"])):
			workbench._add_button.pressed.emit()
	workbench._prep_button.pressed.emit()
	_check(manager.get_order(id)["status"] == "ready_to_serve", "matching recipe completes roll")
	workbench._serve_button.pressed.emit()
	workbench._serve_button.pressed.emit()
	_check(manager.get_order(id)["status"] == "served" and workbench._served_count == 1, "delivery counts once")

	var next: Dictionary = manager.create_order()
	var expired_id: String = next["order_id"]
	manager.accept_order(expired_id)
	workbench._roast_button.pressed.emit()
	workbench._set_paused(true)
	before = manager.elapsed_seconds
	workbench._process(5.0)
	_check(manager.elapsed_seconds == before and workbench._roasting.has(expired_id), "pause preserves clock and roast")
	workbench._set_paused(false)
	workbench._process(float(next["patience_seconds"]))
	_check(manager.get_order(expired_id)["status"] == "expired", "patience expires outside the order station")
	_check(workbench._roasting.is_empty(), "expiry clears oven")
	_check(not manager.transition_order(expired_id, "served"), "expired ticket cannot be delivered")
	workbench.queue_free()
	await process_frame
	print("Playable shift integration: %d failures." % _failures)
	quit(0 if _failures == 0 else 1)


func _check(result: bool, description: String) -> void:
	if not result:
		_failures += 1
		push_error(description)
