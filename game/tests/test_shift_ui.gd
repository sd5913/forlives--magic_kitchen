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
	game.session.accept_current()
	game.session.navigate("roast")
	game.session.perform_action(1)
	game.session.advance_time(12.0)
	assert(game.session.station == "roast" and game.session.current_food().stage == "roasting")
	await capture("roast")
	game.session.perform_action(2)
	game.session.perform_action(3)
	game.session.advance_time(1.0)
	game.session.navigate("prepare")
	game.session.perform_action(1)
	assert(game.session.station == "prepare" and game.session.current_food().stage == "preparing")
	await capture("prepare")
	game.session.perform_action(3)
	game.session.perform_action(4)
	game.session.perform_action(5)
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
	print("Shared shift UI: seven rendered states; %d failures" % failures)
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
