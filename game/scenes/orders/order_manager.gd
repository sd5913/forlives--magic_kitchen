class_name DuckOrderManager
extends Node
## Order-station state only. Other stations consume snapshots and report transitions.

signal order_created(order: Dictionary)
signal order_accepted(order: Dictionary)
signal order_selected(order_id: String)
signal order_updated(order: Dictionary)
signal order_expired(order_id: String)
signal orders_reset

const CATALOG_PATH := "res://data/order_recipes.json"
const MAX_ACTIVE_ORDERS := 3
const MAX_VISIBLE_ORDERS := 4
const TRANSITIONS := {
	"accepted": ["roasting"],
	"roasting": ["preparing"],
	"preparing": ["ready_to_serve"],
	"ready_to_serve": ["served"],
}

var catalog: Dictionary = {}
var catalog_error := ""
var selected_order_id := ""
var elapsed_seconds := 0.0
var _orders: Array[Dictionary] = []
var _sequence := 0
var _recipe_cursor := 0


func _init() -> void:
	load_catalog()


func load_catalog(path: String = CATALOG_PATH) -> bool:
	catalog = {}
	catalog_error = ""
	if not FileAccess.file_exists(path):
		catalog_error = "Recipe catalog is missing: " + path
		return false
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		catalog_error = "Recipe catalog is not valid JSON."
		return false
	if not parser.data is Dictionary:
		catalog_error = "Recipe catalog must be an object."
		return false
	var data: Dictionary = parser.data
	if not data.get("ingredients") is Dictionary or not data.get("recipes") is Array or not data.get("customers") is Array:
		catalog_error = "Recipe catalog needs ingredients, recipes and customers."
		return false
	if data["recipes"].is_empty() or data["customers"].is_empty():
		catalog_error = "Recipe catalog cannot be empty."
		return false
	for recipe in data["recipes"]:
		if not recipe is Dictionary or not recipe.get("ingredients") is Array or float(recipe.get("patience_seconds", 0)) <= 0:
			catalog_error = "Recipe has invalid ingredients or patience."
			return false
		for item in recipe["ingredients"]:
			if not item is Dictionary or not data["ingredients"].has(item.get("id", "")) or int(item.get("quantity", 0)) <= 0:
				catalog_error = "Recipe references an invalid ingredient."
				return false
		for excluded_id in recipe.get("excluded", []):
			if not data["ingredients"].has(excluded_id):
				catalog_error = "Recipe excludes an unknown ingredient."
				return false
	catalog = data
	return true


func create_order(recipe_id: String = "") -> Dictionary:
	if not catalog_error.is_empty() or get_visible_orders().size() >= MAX_VISIBLE_ORDERS:
		return {}
	# One unaccepted guest at a time; accepted orders remain visible.
	for entry in _orders:
		if entry["status"] == "pending":
			return {}
	var recipe: Dictionary = {}
	if recipe_id.is_empty():
		recipe = catalog["recipes"][_recipe_cursor % catalog["recipes"].size()]
	else:
		for candidate in catalog["recipes"]:
			if candidate["id"] == recipe_id:
				recipe = candidate
	if recipe.is_empty():
		return {}
	var customer: Dictionary = catalog["customers"][_recipe_cursor % catalog["customers"].size()]
	_recipe_cursor += 1
	_sequence += 1
	var order := {
		"schema_version": 1,
		"order_id": "MK-%03d" % _sequence,
		"recipe_id": recipe["id"],
		"recipe_name": recipe["name"].duplicate(true),
		"customer_id": customer["id"],
		"customer_name": customer["name"].duplicate(true),
		"portrait": customer["portrait"],
		"ingredients": recipe["ingredients"].duplicate(true),
		"excluded_ingredients": recipe["excluded"].duplicate(true),
		"special_request": recipe["note"].duplicate(true),
		"status": "pending",
		"arrived_at_seconds": elapsed_seconds,
		"accepted_at_seconds": -1.0,
		"patience_seconds": float(recipe["patience_seconds"]),
		"remaining_seconds": float(recipe["patience_seconds"]),
		"elapsed_wait_seconds": 0.0,
		"accepted_wait_seconds": 0.0,
	}
	_orders.append(order)
	order_created.emit(order.duplicate(true))
	select_order(order["order_id"])
	return order.duplicate(true)


func accept_order(order_id: String) -> bool:
	var index := _find_order(order_id)
	if index < 0 or _orders[index]["status"] != "pending" or get_active_count() >= MAX_ACTIVE_ORDERS:
		return false
	_orders[index]["status"] = "accepted"
	_orders[index]["accepted_at_seconds"] = elapsed_seconds
	order_accepted.emit(_orders[index].duplicate(true))
	order_updated.emit(_orders[index].duplicate(true))
	return true


func select_order(order_id: String) -> bool:
	var order := get_order(order_id)
	if order.is_empty() or order["status"] in ["served", "expired"]:
		return false
	selected_order_id = order_id
	order_selected.emit(order_id)
	return true


func transition_order(order_id: String, next_status: String) -> bool:
	var index := _find_order(order_id)
	if index < 0:
		return false
	var current: String = _orders[index]["status"]
	if not next_status in TRANSITIONS.get(current, []):
		return false
	_orders[index]["status"] = next_status
	order_updated.emit(_orders[index].duplicate(true))
	_clear_closed_selection()
	return true


func advance_time(delta: float) -> void:
	if delta <= 0.0:
		return
	elapsed_seconds += delta
	var expired_ids: Array[String] = []
	for order in _orders:
		if order["status"] in ["expired", "served"]:
			continue
		order["elapsed_wait_seconds"] = elapsed_seconds - float(order["arrived_at_seconds"])
		order["remaining_seconds"] = maxf(0.0, float(order["patience_seconds"]) - float(order["elapsed_wait_seconds"]))
		if float(order["accepted_at_seconds"]) >= 0:
			order["accepted_wait_seconds"] = elapsed_seconds - float(order["accepted_at_seconds"])
		if float(order["remaining_seconds"]) <= 0:
			order["status"] = "expired"
			expired_ids.append(order["order_id"])
			order_updated.emit(order.duplicate(true))
	_clear_closed_selection()
	for order_id in expired_ids:
		order_expired.emit(order_id)


func get_order(order_id: String) -> Dictionary:
	var index := _find_order(order_id)
	return {} if index < 0 else _orders[index].duplicate(true)


func get_visible_orders() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for order in _orders:
		if not order["status"] in ["served", "expired"]:
			result.append(order.duplicate(true))
	return result


func get_active_count() -> int:
	var count := 0
	for order in _orders:
		if not order["status"] in ["pending", "served", "expired"]:
			count += 1
	return count


func reset_orders() -> void:
	_orders.clear()
	selected_order_id = ""
	elapsed_seconds = 0.0
	_recipe_cursor = 0
	# Keep the sequence monotonic so a reset does not reuse another station's IDs.
	orders_reset.emit()


func _find_order(order_id: String) -> int:
	for index in range(_orders.size()):
		if _orders[index]["order_id"] == order_id:
			return index
	return -1


func _clear_closed_selection() -> void:
	var selected := get_order(selected_order_id)
	if selected.is_empty() or selected["status"] in ["expired", "served"]:
		selected_order_id = ""
		var live := get_visible_orders()
		if not live.is_empty():
			select_order(live[0]["order_id"])
