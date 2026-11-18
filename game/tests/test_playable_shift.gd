extends SceneTree

const Workbench = preload("res://scenes/workbench.tscn")
var _failures := 0
var _checks := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var workbench = Workbench.instantiate()
	root.add_child(workbench)
	workbench.set_process(false)
	var panel = workbench.get_node("OrderPanel")
	var station = panel._station
	_check(is_instance_valid(station) and station.visible, "project starts at the restaurant order station")
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
	await _capture("shift_ready")
	workbench._serve_button.pressed.emit()
	workbench._serve_button.pressed.emit()
	_check(manager.get_order(id)["status"] == "served" and workbench._served_count == 1, "delivery counts once")

	await _capture("shift_served")
	# Rendering can move OS focus; drive focus explicitly for simulated time below.
	workbench._focused = true

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

	# Switch tickets with one oven and independent ingredient selections.
	manager.reset_orders()
	var first: Dictionary = manager.create_order()
	var first_id: String = first["order_id"]
	manager.accept_order(first_id)
	workbench._start_roast()
	var second: Dictionary = manager.create_order()
	var second_id: String = second["order_id"]
	manager.accept_order(second_id)
	workbench._start_roast()
	_check(manager.get_order(second_id)["status"] == "accepted", "occupied oven rejects another ticket")
	workbench._process(4.0)
	_check(manager.get_order(first_id)["status"] == "preparing", "oven completes its original ticket after selection changes")
	_check(not workbench._roast_button.disabled, "freed oven enables selected waiting ticket")
	workbench._start_roast()
	workbench._process(4.0)
	manager.select_order(first_id)
	workbench._ingredient_picker.select(0)
	workbench._add_ingredient()
	var saved: Dictionary = workbench._fillings[first_id].duplicate(true)
	manager.select_order(second_id)
	workbench._add_ingredient()
	workbench._clear_ingredients()
	_check(workbench._fillings[first_id] == saved and not workbench._fillings.has(second_id), "clearing another ticket preserves first ticket ingredients")
	manager.select_order(first_id)
	_check(workbench._fillings[first_id] == saved, "reopening a ticket keeps its ingredients")
	workbench._focused = false
	before = manager.elapsed_seconds
	workbench._process(10.0)
	_check(manager.elapsed_seconds == before, "unfocused window freezes the shared clock")
	workbench._focused = true

	# A restart modal must stop both the host clock and station arrivals.
	station.show()
	station._auto_arrivals = true
	station._auto_elapsed = 17.5
	workbench._confirm_restart()
	var dialog: ConfirmationDialog = workbench.get_child(workbench.get_child_count() - 1)
	before = manager.elapsed_seconds
	var arrival_before: float = station._auto_elapsed
	workbench._process(2.0)
	station._process(2.0)
	_check(manager.elapsed_seconds == before and station._auto_elapsed == arrival_before, "restart dialog freezes clock and guest arrivals")
	_check(workbench._add_button.disabled, "restart dialog disables preparation")
	dialog.canceled.emit()
	_check(not workbench._paused and not station.paused and not workbench._add_button.disabled, "cancel restores running state and controls")
	_check(workbench._fillings[first_id] == saved, "cancel preserves ingredients")
	await process_frame
	workbench._set_paused(true)
	station.paused = true
	workbench._confirm_restart()
	dialog = workbench.get_child(workbench.get_child_count() - 1)
	dialog.confirmed.emit()
	_check(workbench._paused and station.paused, "restart preserves an existing pause")
	_check(workbench._roasting.is_empty() and workbench._fillings.is_empty() and workbench._served_count == 0, "restart clears shift food and score")
	_check(manager.get_order(first_id).is_empty() and manager.get_order(second_id).is_empty(), "restart removes old tickets")
	_check(not manager.selected_order_id.is_empty() and manager.elapsed_seconds == 0.0 and station._auto_elapsed == 0.0, "restart creates a fresh ticket and resets timers")
	workbench.queue_free()
	await process_frame
	print("Playable shift integration: %d checks, %d failures." % [_checks, _failures])
	quit(0 if _failures == 0 else 1)


func _check(result: bool, description: String) -> void:
	_checks += 1
	if not result:
		_failures += 1
		push_error(description)


func _capture(filename: String) -> void:
	var directory := OS.get_environment("MAGIC_KITCHEN_SCREENSHOT_DIR")
	if directory.is_empty():
		return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(directory)
	var error := root.get_texture().get_image().save_png(directory.path_join(filename + ".png"))
	_check(error == OK, "save rendered shift evidence: " + filename)
