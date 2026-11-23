extends SceneTree
const Session = preload("res://scenes/shift/shift_session.gd")
const Gate = preload("res://scenes/shift/gesture_gate.gd")
var checks := 0
var failures := 0
var session


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(description)


func _run() -> void:
	session = Session.new()
	root.add_child(session)
	check(session.created_count == 1, "initial guest")
	var id: String = session.manager.selected_order_id
	check(not session.perform_action(1), "no cooking before acceptance")
	check(session.accept_current(), "accept ticket once")
	check(not session.accept_current(), "duplicate acceptance rejected")
	session.navigate("roast")
	check(not session.perform_action(2), "cannot take out before roasting")
	check(session.perform_action(1), "place first duck")
	check(not session.perform_action(1), "one oven slot per order")
	session.advance_time(12.0)
	check(session.current_food().stage == "roasting", "no automatic take out")
	check(session.roast_quality(11.999) == "raw" and session.roast_quality(12.0) == "cooked" and session.roast_quality(18.0) == "burnt", "exact heat boundaries")
	session.set_paused(true)
	var elapsed: float = session.manager.elapsed_seconds
	session.advance_time(5.0)
	check(session.manager.elapsed_seconds == elapsed and not session.perform_action(2), "pause freezes clocks and actions")
	session.set_paused(false)
	check(session.perform_action(2), "take out")
	var locked: float = session.current_food().roast_seconds
	session.advance_time(2.0)
	check(session.current_food().roast_seconds == locked and session.oven_count() == 0, "take out locks heat and frees slot")
	check(not session.perform_action(2) and session.perform_action(3), "slice once after removal")
	session.advance_time(1.0)
	check(session.manager.get_order(id).status == "preparing", "slicing unlocks prep")
	session.navigate("prepare")
	check(not session.perform_action(0), "empty wrap refused")
	check(session.perform_action(1), "duck added explicitly")
	check(not session.perform_action(1), "no duplicate portions")
	check(session.perform_action(2) and "hawthorn" in session.current_food().ingredients, "2 maps to hawthorn")
	check(session.remove_ingredient("hawthorn"), "wrong side can be removed")
	check(not session.remove_ingredient("duck_meat"), "duck cannot be discarded")
	check(session.perform_action(4) and "cucumber" in session.current_food().ingredients, "4 maps to cucumber")
	session.perform_action(3)
	session.perform_action(5)
	check(session.perform_action(0), "fist wraps with duck present")
	check(not session.remove_ingredient("scallion") and not session.perform_action(2), "rolling locks ingredients immediately")
	check(not session.serve_current(), "cannot submit during wrap animation")
	session.advance_time(1.0)
	check(session.serve_current(), "complete roll submitted")
	check(session.results.size() == 1 and not session.serve_current(), "one result per ticket")
	check(session.rating.prep_score == 100 and session.rating.roast_score == 100, "correct classic recipe and roast scores")
	check(session.rating.total == roundi((float(session.rating.wait_score) + 200) / 3), "three score average rounded")
	elapsed = session.manager.elapsed_seconds
	session.advance_time(3.1)
	check(session.manager.elapsed_seconds == elapsed, "rating freezes all kitchen timers")
	check(session.can_return() and session.return_to_work(), "return unlocks after tasting")

	# Arrivals continue in all stations, allow multiple pending guests, and never overwrite selection.
	session.restart()
	id = session.manager.selected_order_id
	session.navigate("roast")
	session.advance_time(60.0)
	check(session.created_count == 4 and session.manager.get_visible_orders().size() == 4, "20-second arrivals include multiple pending tickets")
	check(session.manager.selected_order_id == id, "new arrivals do not steal selected ticket")
	session.advance_time(20.0)
	check(session.created_count == 4, "fifth arrival delayed at capacity")
	for order in session.manager.get_visible_orders():
		session.manager.accept_order(order.order_id)
	var orders: Array = session.manager.get_visible_orders()
	for i in range(2):
		session.select_order(orders[i].order_id)
		check(session.perform_action(1), "two independent oven slots")
	session.select_order(orders[2].order_id)
	check(not session.perform_action(1) and session.oven_count() == 2, "third duck rejected while full")
	session.select_order(orders[0].order_id)
	session.perform_action(2)
	session.select_order(orders[2].order_id)
	check(session.perform_action(1), "removed duck frees slot for another ticket")
	session.advance_time(40.1)
	check(session.manager.get_order(id).status == "expired" and not session.food.has(id), "expiry clears food and roast")
	check(session.created_count == 5, "delayed guest arrives when a slot opens")
	session.advance_time(200.0)
	check(session.summary_visible and session.summary().expired == 5, "all expired reaches summary")
	check(not session.summary().success and session.summary().average == 0, "no-delivery summary avoids division by zero")
	session.restart()
	check(session.results.is_empty() and session.food.size() == 1 and session.oven_count() == 0 and session.manager.elapsed_seconds == 0.0, "restart clears all state")
	check(session.manager.get_order(id).is_empty(), "old IDs invalid after restart")

	# Imperfect recipe is deliverable; ingredients are scored rather than blocking forever.
	session.accept_current()
	session.navigate("roast")
	session.perform_action(1)
	session.perform_action(2)
	session.perform_action(3)
	session.advance_time(1.0)
	session.navigate("prepare")
	session.perform_action(1)
	session.perform_action(2) # extra hawthorn, missing classic sides/sauce
	session.perform_action(0)
	session.advance_time(1.0)
	check(session.serve_current() and session.rating.roast_score == 40 and session.rating.prep_score == 20, "raw imperfect wrap scores actual output")
	check(not session.return_to_work(), "early return refused")

	var gate := Gate.new()
	check(gate.sample(1, 0.49) == -1 and gate.sample(1, 0.01) == 1, "gesture stable for half a second")
	check(gate.sample(1, 2.0) == -1 and gate.sample(2, 1.0) == -1, "held or changed pose cannot bypass release")
	gate.sample(-1, 0.24)
	check(gate.sample(2, 1.0) == -1, "insufficient neutral release")
	gate.sample(-1, 0.25)
	check(gate.sample(2, 0.5) == 2, "neutral release rearms")
	gate.invalidate()
	check(gate.sample(2, 5.0) == -1, "context change requires release")
	gate.sample(-1, 0.25)
	check(gate.sample(0, 0.5) == 0, "fist recognized independently of ingredient mapping")

	session.queue_free()
	await process_frame
	print("Six-part shift flow: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
