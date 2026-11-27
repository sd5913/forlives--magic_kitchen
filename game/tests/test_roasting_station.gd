extends SceneTree
## Integration checks for the approved roasting layers and shared-session actions.
const Game = preload("res://scenes/shift/shift_game.tscn")
var game: Control


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	game = Game.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.receiver.set_process(false)
	root.focus_exited.disconnect(game._on_focus_lost)
	game.session.accept_current()
	game.session.navigate("roast")
	await capture("waiting")
	assert(game._roasting_view.buttons.action_1.disabled == false)
	assert(game._roasting_view.buttons.action_2.disabled)
	game._roasting_view.buttons.action_3.pressed.emit()
	assert(game.session.current_food().stage == "waiting", "invalid slicing cannot change the food")
	game._roasting_view.buttons.action_1.pressed.emit()
	await capture("undercooked")
	var id: String = game.session.manager.selected_order_id
	assert(game._roasting_view.ducks[id].texture.resource_path.ends_with("duck_undercooked.png"))
	game.session.advance_time(12.0)
	game._roasting_view.refresh_times()
	assert(game._roasting_view.ducks[id].texture.resource_path.ends_with("duck_ready.png"))
	assert(is_equal_approx(game._roasting_view.pointer.position.x, 946.0 + 536.0 / 3.0))
	await capture("ready")
	game.session.advance_time(6.0)
	game._roasting_view.refresh_times()
	assert(game._roasting_view.ducks[id].texture.resource_path.ends_with("duck_burnt.png"))
	await capture("burnt")
	game._roasting_view.buttons.action_2.pressed.emit()
	await capture("removed")
	var locked_time: float = game.session.current_food().roast_seconds
	game.session.advance_time(2.0)
	assert(game.session.current_food().roast_seconds == locked_time, "removing the duck locks doneness")
	game._roasting_view.buttons.action_3.pressed.emit()
	game.session.advance_time(1.0)
	await capture("sliced")
	assert(game.session.current_food().stage == "preparing")
	game.session.advance_time(1.0)
	var next_id: String = game.session.manager.get_visible_orders()[1].order_id
	game._select(next_id)
	game.session.accept_current()
	game.session.perform_action(1)
	game._refresh()
	assert(game._roasting_view.ducks.has(next_id) and not game._roasting_view.ducks.has(id), "oven shows only roasting orders")
	game.session.advance_time(20.0)
	var third_id: String = game.session.manager.get_visible_orders()[2].order_id
	game._select(third_id)
	game.session.accept_current()
	game.session.perform_action(1)
	await capture("two_ovens")
	assert(game._roasting_view.ducks.size() == 2, "two active orders share the oven")
	assert(game._roasting_view.ducks[next_id].texture.resource_path.ends_with("duck_burnt.png"))
	assert(game._roasting_view.ducks[third_id].texture.resource_path.ends_with("duck_undercooked.png"))
	game._select(id)
	game._refresh()
	assert(game._roasting_view.buttons.action_1.disabled, "completed order cannot load again")
	game._pause()
	game._refresh()
	assert(game._roasting_view.buttons.action_2.disabled)
	var before: float = game.session.food[next_id].roast_seconds
	game.session.advance_time(1.0)
	assert(game.session.food[next_id].roast_seconds == before)
	game._pause()
	root.size = Vector2i(960, 540)
	root.content_scale_size = Vector2i(960, 540)
	game.size = Vector2(960, 540)
	game._fit()
	await capture("small")
	assert(game._canvas.get_global_rect().end.x <= root.size.x + 1)
	assert(game._canvas.get_global_rect().end.y <= root.size.y + 1)
	game.language = "zh"
	await capture("zh")
	game._navigate("prepare")
	game._refresh()
	assert(is_instance_valid(game._preparation_view))
	game.queue_free()
	await process_frame
	print("Roasting station: food states, live heat, locked doneness, ticket binding, pause, resize and handoff passed")
	quit()


func capture(filename: String) -> void:
	game._refresh()
	await process_frame
	await process_frame
	var directory := OS.get_environment("MAGIC_KITCHEN_SCREENSHOT_DIR")
	if directory.is_empty():
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(directory)
	assert(root.get_texture().get_image().save_png(directory.path_join("roasting_" + filename + ".png")) == OK)
