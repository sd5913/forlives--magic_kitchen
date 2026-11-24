extends SceneTree
const Game = preload("res://scenes/shift/shift_game.tscn")
var game
var checks := 0
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func verify(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(description)


func _run() -> void:
	root.content_scale_size = Vector2i(1536, 1024)
	root.size = Vector2i(1536, 1024)
	game = Game.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.receiver.set_process(false)
	root.focus_exited.disconnect(game._on_focus_lost)
	verify(game._order_view != null, "approved counter is default")
	verify(game._canvas.size == Vector2(1536, 1024), "approved canvas dimensions")
	verify(game._order_view.font.resource_path.ends_with("bree_serif_regular.ttf"), "exact design font")
	verify(game._order_view.buttons.nav_order.position == Vector2(362, 8), "source navigation position")
	verify(game._order_view.buttons.accept.position == Vector2(1192, 682), "source confirmation position")
	verify(game._order_view.buttons.expand.size == Vector2(64, 64), "source icon hit area")
	await capture("approved_order_initial")
	var id: String = game.session.manager.selected_order_id
	game._order_view.buttons.accept.pressed.emit()
	game._refresh()
	verify(game.session.manager.get_order(id).status == "accepted", "confirm binds shared order")
	verify(game._order_view.buttons.accept.disabled, "no duplicate acceptance")
	await capture("approved_order_accepted")
	game._show_details()
	verify(game._order_view.overlay_open() and not game.session.paused, "details keep time running")
	var before: float = game.session.manager.elapsed_seconds
	game._process(1.0)
	verify(game.session.manager.elapsed_seconds > before, "reading details does not pause clock")
	verify(game._order_view.overlay_open(), "refresh preserves open detail")
	await capture("approved_ticket_detail")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	game._input(escape)
	verify(not game._popup_open() and not game.session.paused, "Esc closes without pausing")
	escape.pressed = false
	game._input(escape)
	game.session.advance_time(40.0)
	game._refresh()
	verify(game._order_view.time_labels.size() == 2, "other tickets stay compact")
	await capture("approved_order_queue")
	game._show_orders()
	verify(game._order_view._overlay_mode == "all", "approved all-orders overlay")
	await capture("approved_all_orders")
	game._close_popup()
	game._pause()
	game._refresh()
	verify(game._order_view._overlay_mode == "pause", "approved pause design")
	before = game.session.manager.elapsed_seconds
	game._process(3.0)
	verify(game.session.manager.elapsed_seconds == before, "pause freezes time")
	await capture("approved_paused")
	game._order_view.buttons.resume.pressed.emit()
	game._refresh()
	verify(not game.session.paused and not game._popup_open(), "resume closes pause overlay")
	game._order_view.buttons.nav_roast.pressed.emit()
	game._refresh()
	verify(game.session.station == "roast" and game._order_view == null, "navigation connects shared roasting")
	game._navigate("order")
	game._refresh()
	verify(game.session.manager.selected_order_id == id, "return retains ticket")
	game.language = "zh"
	game._refresh()
	await capture("approved_order_zh")
	root.content_scale_size = Vector2i(960, 540)
	root.size = Vector2i(960, 540)
	await process_frame
	game._fit()
	verify(game._canvas.get_global_rect().end.x <= 960.1 and game._canvas.get_global_rect().end.y <= 540.1, "small viewport fits without cropping")
	await capture("approved_order_small")
	game.queue_free()
	await process_frame
	print("Approved order UI: %d checks, %d failures; eight visual states" % [checks, failures])
	quit(0 if failures == 0 else 1)


func capture(name: String) -> void:
	await process_frame
	await process_frame
	var directory := OS.get_environment("MAGIC_KITCHEN_SCREENSHOT_DIR")
	if directory.is_empty():
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(directory)
	verify(root.get_texture().get_image().save_png(directory.path_join(name + ".png")) == OK, "save rendered screen")
