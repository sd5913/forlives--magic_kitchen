extends SceneTree
const Game = preload("res://scenes/shift/shift_game.tscn")
var game
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	game = Game.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.receiver.set_process(false)
	root.focus_exited.disconnect(game._on_focus_lost)
	await capture("order")
	game._order_view.buttons.accept.pressed.emit()
	assert(game.session.manager.get_order(game.session.manager.selected_order_id).status == "accepted")
	game._order_view.buttons.nav_roast.pressed.emit()
	game._refresh()
	assert(game.session.station == "roast")
	game.session.perform_action(1)
	game._show_orders()
	await process_frame
	assert(game._popup is PanelContainer and not game._popup is Window, "ticket overlay stays in the game window")
	assert(not game.session.paused, "ticket overlay does not pause")
	var overlay_start: float = game.session.manager.elapsed_seconds
	game._process(1.0)
	assert(game.session.manager.elapsed_seconds > overlay_start, "ticket overlay keeps shared clock running")
	var overlay_key := InputEventKey.new()
	overlay_key.keycode = KEY_2
	overlay_key.pressed = true
	game._input(overlay_key)
	assert(game.session.current_food().stage == "roasting", "overlay blocks background gameplay keys")
	game._receive_gesture(2)
	assert(game.session.current_food().stage == "roasting", "overlay blocks background camera actions")
	await capture("all_tickets")
	game._close_popup()
	assert(not game._popup_open() and not game.session.paused, "closing tickets preserves running state")
	game.session.advance_time(11.0)
	assert(game.session.station == "roast" and game.session.current_food().stage == "roasting")
	await capture("roast")
	game.session.perform_action(2)
	game.session.perform_action(3)
	game.session.advance_time(1.0)
	game.session.navigate("prepare")
	game.session.perform_action(1)
	assert(game.session.station == "prepare" and game.session.current_food().stage == "preparing")
	assert(game._recipe_progress_text().begins_with("Recipe: 1 / 4 · Extra: 0"), "progress uses selected recipe")
	game.session.perform_action(2)
	assert(game._recipe_progress_text().begins_with("Recipe: 1 / 4 · Extra: 1"), "extra garnish is not mistaken for required progress")
	game.session.remove_ingredient("hawthorn")
	await capture("prepare")
	game.session.perform_action(3)
	game.session.perform_action(4)
	game.session.perform_action(5)
	assert(game._recipe_progress_text().begins_with("Recipe: 4 / 4 · Extra: 0"), "correct classic recipe reports complete")
	game.session.perform_action(0)
	game.session.advance_time(1.0)
	game.session.serve_current()
	game.session.advance_time(3.0)
	assert(not game.session.rating.is_empty())
	await capture("rating")
	game.session.return_to_work()
	game.session.advance_time(300.0)
	assert(game.session.summary_visible)
	await capture("summary")
	game.session.restart()
	game.language = "zh"
	await capture("order_zh")
	root.size = Vector2i(960, 540)
	game._fit()
	await capture("order_small")
	# Check held keys and focus lifecycle through the actual host entry points.
	game._on_focus_lost()
	var before: float = game.session.manager.elapsed_seconds
	game._process(1.0)
	if not game.session.paused or game.session.manager.elapsed_seconds != before:
		failures += 1
	game.queue_free()
	await process_frame
	print("Shared shift UI: eight rendered states; %d failures" % failures)
	quit(0 if failures == 0 else 1)


func capture(filename: String) -> void:
	game._refresh()
	await process_frame
	await process_frame
	var directory := OS.get_environment("MAGIC_KITCHEN_SCREENSHOT_DIR")
	if directory.is_empty():
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(directory)
	if root.get_texture().get_image().save_png(directory.path_join(filename + ".png")) != OK:
		failures += 1


func click_caption(caption: String) -> void:
	game._refresh()
	await process_frame
	var target: Button
	for node in game._canvas.get_children():
		if node is Button and node.text == caption:
			target = node
			break
	assert(target != null and not target.disabled, "clickable control: " + caption)
	var point := target.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = true
	root.push_input(event, true)
	await process_frame
	event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = false
	root.push_input(event, true)
	await process_frame
