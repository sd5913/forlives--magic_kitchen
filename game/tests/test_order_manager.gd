extends SceneTree

const Manager = preload("res://scenes/orders/order_manager.gd")
var failures := 0
var checks := 0
var accepted_count := 0
var expired_count := 0


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func _run() -> void:
	var manager := Manager.new()
	root.add_child(manager)
	manager.order_accepted.connect(func(_order: Dictionary): accepted_count += 1)
	manager.order_expired.connect(func(_id: String): expired_count += 1)
	_check(manager.catalog_error.is_empty(), "catalog loads")
	_check(manager.catalog["ingredients"].size() == 8, "all eight GDD ingredients exist")
	_check(manager.create_order("unknown").is_empty(), "unknown recipe rejected")
	var first := manager.create_order("no_scallion")
	_check(not first.is_empty(), "create guest")
	var id: String = first["order_id"]
	_check(first["status"] == "pending", "guest is not silently accepted")
	_check(first["excluded_ingredients"] == ["scallion"], "special requirement encoded")
	_check(first["ingredients"][3]["quantity"] == 2, "ingredient amount encoded")
	_check(manager.create_order().is_empty(), "pending guest cannot be overwritten")
	first["ingredients"][0]["quantity"] = 99
	_check(manager.get_order(id)["ingredients"][0]["quantity"] == 1, "create snapshot cannot mutate manager")
	_check(not manager.accept_order("missing"), "missing order rejected")
	_check(manager.accept_order(id), "accept pending order")
	_check(not manager.accept_order(id), "duplicate acceptance rejected")
	_check(accepted_count == 1, "single accepted event")
	var copy := manager.get_order(id)
	copy["excluded_ingredients"].clear()
	_check(manager.get_order(id)["excluded_ingredients"] == ["scallion"], "nested snapshots isolated")
	_check(not manager.transition_order(id, "served"), "cannot jump directly to served")
	var second := manager.create_order()
	manager.accept_order(second["order_id"])
	var third := manager.create_order()
	manager.accept_order(third["order_id"])
	var fourth := manager.create_order()
	_check(manager.get_visible_orders().size() == 4, "three kitchen orders and one waiting guest")
	_check(not manager.accept_order(fourth["order_id"]), "kitchen capacity enforced")
	_check(manager.get_order(fourth["order_id"])["status"] == "pending", "full kitchen preserves pending ticket")
	manager.select_order(second["order_id"])
	_check(manager.get_order(id)["status"] == "accepted", "selection does not alter another order")
	_check(manager.transition_order(id, "roasting"), "oven transition")
	_check(manager.transition_order(id, "preparing"), "prep transition")
	_check(manager.transition_order(id, "ready_to_serve"), "ready transition")
	_check(manager.transition_order(id, "served"), "delivery transition")
	_check(not manager.transition_order(id, "served"), "duplicate delivery rejected")
	_check(manager.accept_order(fourth["order_id"]), "served order frees capacity")
	manager.advance_time(-1)
	_check(manager.elapsed_seconds == 0, "negative time ignored")
	manager.advance_time(15)
	_check(is_equal_approx(manager.get_order(second["order_id"])["elapsed_wait_seconds"], 15), "waiting clock updated")
	_check(is_equal_approx(manager.get_order(id)["elapsed_wait_seconds"], 0), "served waiting clock frozen")
	manager.advance_time(500)
	_check(manager.get_visible_orders().is_empty(), "expired tickets removed from live queue")
	_check(expired_count == 3, "expired event once per live order")
	manager.advance_time(500)
	_check(expired_count == 3, "expiry not repeated")
	_check(not manager.accept_order(second["order_id"]), "cannot accept departed guest")
	_check(not manager.select_order(id), "closed ticket cannot be selected")
	manager.reset_orders()
	var fresh := manager.create_order()
	_check(fresh["order_id"] != id, "reset does not reuse old ID")
	_check(manager.elapsed_seconds == 0, "reset clears clock")
	_check(not manager.load_catalog("res://data/not_present.json"), "missing file handled without exception")
	_check(manager.create_order().is_empty(), "no creation when catalog invalid")
	_check(manager.load_catalog(), "recover by reloading valid catalog")
	manager.free()
	print("Order manager: %d checks, %d failures." % [checks, failures])
	quit(1 if failures else 0)
