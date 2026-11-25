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


func labels(node: Node) -> String:
	var text: String = node.text + "\n" if node is Label else ""
	for child in node.get_children():
		text += labels(child)
	return text


func _run() -> void:
	game = Game.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.receiver.set_process(false)
	root.focus_exited.disconnect(game._on_focus_lost)
	game._navigate("prepare")
	game._refresh()
	check(game._preparation_view.view.feedback.text.contains("Accept this ticket"), "pending ticket gives an acceptance destination")
	game.session.accept_current()
	game._refresh()
	check(game._preparation_view.view.feedback.text.contains("Roasting Station"), "accepted ticket directs player to roast")
	game._navigate("roast")
	game.session.perform_action(1)
	game.session.advance_time(12.0)
	game.session.perform_action(2)
	game.session.perform_action(3)
	game.session.advance_time(1.0)
	game._navigate("prepare")
	game._refresh()
	check(game._preparation_view.preparation_hint().contains("Sliced Duck"), "recipe hint lists actual missing duck")
	game._preparation_view._add_ingredient("duck")
	game._preparation_view._add_ingredient("hawthorn")
	game._refresh()
	check(game._preparation_view.view.feedback.text.contains("Extra: Hawthorn"), "wrong ingredient has a specific correction hint")
	game._preparation_view._remove_ingredient("hawthorn")
	for ingredient in ["scallion", "cucumber", "sauce"]:
		game._preparation_view._add_ingredient(ingredient)
	game._refresh()
	check(game._preparation_view.view.feedback.text.contains("press Space"), "matched recipe explains rolling input")
	check(game._preparation_view.view.get_node("Gestures/Card2/Status").text == "3 / 3 required sides", "side progress follows the selected recipe")
	# Six real catalog items must fit into the contributor's five-row mini-ticket.
	var recipe: Dictionary = game.session.manager.catalog.recipes[0].duplicate(true)
	recipe.id = "full_recipe_display_fixture"
	recipe.ingredients.append({"id": "hawthorn", "quantity": 1})
	game.session.manager.catalog.recipes.append(recipe)
	var selected: String = game.session.manager.selected_order_id
	var other: Dictionary = game.session.manager.create_order(recipe.id)
	game.session.manager.select_order(selected)
	game._refresh()
	check(not other.is_empty(), "full-recipe queue fixture created through manager")
	var mini: Control = game._preparation_view.view.get_node("Game/Queue1/Items")
	check(mini.get_node("Row5").visible, "full recipe uses the fifth mini-ticket row")
	var mini_text := labels(mini)
	check(mini_text.contains("Hawthorn") and mini_text.contains("Sweet Bean Sauce") and mini_text.contains("Scallion"), "mini-ticket does not lose a side ingredient")
	game._preparation_view._roll()
	game.session.advance_time(1.0)
	game.session.serve_current()
	game._refresh()
	var total: int = game.session.rating.total
	check(labels(game).contains("Ordering —   Roasting —   Preparation —"), "scores start unrevealed")
	check(not labels(game).contains("/ 100"), "final result is not revealed before station scores")
	await capture("rating_before_scores")
	game._process(0.8)
	check(labels(game).contains("Roasting —   Preparation —") and not labels(game).contains("Ordering —"), "ordering score appears first")
	game._process(0.8)
	check(labels(game).contains("Roasting 100   Preparation —"), "roasting score appears second")
	game._process(0.8)
	check(labels(game).contains("Preparation 100") and not labels(game).contains("/ 100"), "preparation score appears before total")
	check(not game.session.can_return(), "early return remains locked")
	await capture("rating_station_scores")
	game._process(0.6)
	check(game.session.can_return() and labels(game).contains("%d / 100" % total), "total and return unlock at configured three seconds")
	check(game.session.rating.total == total, "presentation does not change scoring")
	await capture("rating_final_scores")
	game.queue_free()
	await process_frame
	print("Demo feedback: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func capture(name: String) -> void:
	await process_frame
	await process_frame
	var output := OS.get_environment("MAGIC_KITCHEN_SCREENSHOT_DIR")
	if output.is_empty():
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(output)
	check(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK, "save feedback state")
