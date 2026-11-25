extends SceneTree
const Game = preload("res://scenes/shift/shift_game.tscn")
var game
var checks := 0
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(description)


func _run() -> void:
	root.content_scale_size = Vector2i(1440, 900)
	root.size = Vector2i(1440, 900)
	game = Game.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.receiver.set_process(false)
	root.focus_exited.disconnect(game._on_focus_lost)
	var id: String = game.session.manager.selected_order_id
	game._navigate("prepare")
	game._refresh()
	check(game._preparation_view != null, "contributor preparation scene is connected")
	check(game._preparation_view.view.ingredient_buttons[0].disabled, "uncooked pending order cannot add duck")
	await capture("preparation_waiting")
	game._navigate("order")
	game.session.accept_current()
	game._navigate("roast")
	game.session.perform_action(1)
	game.session.advance_time(12.0)
	game.session.perform_action(2)
	game.session.perform_action(3)
	game.session.advance_time(1.0)
	game._navigate("prepare")
	game._refresh()
	check(game._preparation_view.order_id == id, "source scene reads shared order ID")
	var view = game._preparation_view
	check(view.view.ingredient_buttons.size() == 5 and not view.view.ingredient_buttons[0].disabled, "source ingredient targets are connected")
	await click_control(view.view.ingredient_buttons[0])
	game._refresh()
	check("duck_meat" in game.session.current_food().ingredients, "source mouse button adds duck to shared food")
	check(game._preparation_view.view.get_node("Game/Fillings/Duck").visible, "source duck layer shows real progress")
	check(game._preparation_view.highlighted_ingredient == "duck", "source number/hand highlight follows shared action")
	game._preparation_view._add_ingredient("hawthorn")
	game._refresh()
	check("hawthorn" in game.session.current_food().ingredients, "source 2 maps to hawthorn")
	check(game._preparation_view.view.order_rows[1].visible, "extra ingredient remains visible for correction")
	await capture("preparation_extra")
	await click_control(game._preparation_view.correction_buttons.hawthorn)
	game._refresh()
	check(not "hawthorn" in game.session.current_food().ingredients, "clicking extra row removes it")
	game.session.advance_time(20.0)
	game._refresh()
	check(game._preparation_view.queue_ids.size() == 1, "queue comes from actual shared arrivals")
	var other: String = game._preparation_view.queue_ids[0]
	game._preparation_view.select_queue_order(0)
	game._refresh()
	check(game.session.manager.selected_order_id == other, "small ticket selects shared ID")
	check(game._preparation_view.view.ingredient_buttons[0].disabled, "pending queue ticket cannot cook")
	game._preparation_view.select_queue_order(0)
	game._refresh()
	check(game.session.manager.selected_order_id == id and "duck_meat" in game.session.current_food().ingredients, "queue round trip preserves food")
	game._navigate("order")
	game._navigate("prepare")
	game._refresh()
	check("duck_meat" in game.session.current_food().ingredients, "station round trip restores source food layer")
	for ingredient in ["scallion", "cucumber", "sauce"]:
		game._preparation_view._add_ingredient(ingredient)
	game._refresh()
	check(game._recipe_progress_text().begins_with("Recipe: 4 / 4"), "source layout uses selected recipe")
	check(not game._preparation_view.view.get_node("Game/Fillings/Hawthorn").visible, "removed source layer stays hidden")
	await capture("preparation_complete_recipe")
	game._pause()
	game._refresh()
	check(game._preparation_view.view.ingredient_buttons[0].disabled and game._preparation_view.view.roll_button.disabled, "pause blocks source controls")
	await capture("preparation_paused")
	game._pause()
	game._refresh()
	game._preparation_view._roll()
	game._refresh()
	check(game.session.current_food().stage == "wrapping", "fist uses shared wrap animation")
	check(game._preparation_view.view.submit_button.disabled and game._preparation_view.view.undo_button.disabled, "wrapping locks submission and correction")
	game.session.advance_time(1.0)
	game._refresh()
	check(game._preparation_view.view.get_node("Game/RolledPlate").visible, "source finished artwork follows ready stage")
	check(not game._preparation_view.view.submit_button.disabled, "ready wrap enables Finish Order")
	await capture("preparation_ready")
	game._preparation_view.view.submit_button.pressed.emit()
	game._refresh()
	check(not game.session.rating.is_empty() and game._preparation_view == null, "source Finish Order reaches actual shared rating")
	check(game.session.rating.order_id == id and game.session.rating.prep_score == 100, "score uses actual submitted recipe")
	await capture("preparation_rating")
	game.session.advance_time(3.1)
	game._return_to_work()
	game._refresh()
	check(game.session.station == "order" and game._order_view != null, "rating returns to approved counter")
	game.queue_free()
	await process_frame
	print("Preparation handoff: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func capture(name: String) -> void:
	await process_frame
	await process_frame
	var output := OS.get_environment("MAGIC_KITCHEN_SCREENSHOT_DIR")
	if output.is_empty():
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(output)
	check(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK, "save source-layout preview")


func click_control(control: Control) -> void:
	await process_frame
	var position := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = position
	root.push_input(motion, true)
	var press := InputEventMouseButton.new()
	press.position = position
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	root.push_input(press, true)
	await process_frame
	press = InputEventMouseButton.new()
	press.position = position
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = false
	root.push_input(press, true)
	await process_frame
