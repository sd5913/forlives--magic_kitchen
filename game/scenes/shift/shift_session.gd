extends Node
## One host owns arrivals, clocks, food and results. UI and device adapters submit intents.
signal changed
signal feedback(message: String)

const Manager = preload("res://scenes/orders/order_manager.gd")
const RULES_PATH := "res://data/shift_rules.json"
var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES_PATH))
var manager := Manager.new()
var food: Dictionary = {}
var results: Array[Dictionary] = []
var station := "order"
var paused := false
var rating: Dictionary = {}
var rating_elapsed := 0.0
var summary_visible := false
var arrivals_elapsed := 0.0
var created_count := 0
var message := "Read the guest's request, then accept the order."


func _ready() -> void:
	manager.name = "OrderManager"
	manager.max_active_orders = int(rules.max_orders)
	manager.max_visible_orders = int(rules.max_orders)
	manager.allow_multiple_pending = true
	# Preserve the original catalog for standalone scenes; adapt a private copy to this flow.
	var recipes: Array = []
	for recipe in manager.catalog.recipes:
		if recipe.id == "sweet":
			continue # Melon/sugar have no input in the five-ingredient team flow.
		var copy: Dictionary = recipe.duplicate(true)
		copy.patience_seconds = float(rules.patience_seconds)
		for item in copy.ingredients:
			item.quantity = 1
		if copy.id == "no_scallion":
			copy.note = {"en": "Cucumber and sauce, no scallion, please.", "zh": "要黄瓜和甜面酱，不要葱。"}
		recipes.append(copy)
	manager.catalog.recipes = recipes
	manager.catalog.ingredients.hawthorn = {"en": "Hawthorn strips", "zh": "山楂条", "icon": "hawthorn"}
	add_child(manager)
	manager.order_expired.connect(_expire)
	restart()


func restart() -> void:
	food.clear()
	results.clear()
	rating.clear()
	rating_elapsed = 0.0
	arrivals_elapsed = 0.0
	created_count = 0
	summary_visible = false
	paused = false
	station = "order"
	manager.reset_orders()
	_arrive()
	_notify("A new shift: five guests, four active tickets and two oven slots.")


func _arrive() -> bool:
	if created_count >= int(rules.shift_orders):
		return false
	var previous := manager.selected_order_id
	var order := manager.create_order()
	if order.is_empty():
		return false
	created_count += 1
	food[order.order_id] = {"stage": "waiting", "roast_seconds": 0.0, "quality": "", "ingredients": [], "animation_seconds": 0.0}
	if not previous.is_empty():
		manager.select_order(previous)
	return true


func advance_time(delta: float) -> void:
	if delta <= 0.0 or paused or summary_visible:
		return
	if not rating.is_empty():
		rating_elapsed += delta
		changed.emit()
		return # Rating freezes arrivals, patience, ovens and preparation until returning.
	# Bounded steps keep automatic arrivals and animation completion consistent on slow frames.
	var remaining := delta
	while remaining > 0.00001 and not summary_visible:
		var step := minf(remaining, 0.25)
		remaining -= step
		manager.advance_time(step)
		for id in food.keys():
			var entry: Dictionary = food[id]
			if entry.stage == "roasting":
				entry.roast_seconds += step
			elif entry.stage in ["slicing", "wrapping"]:
				entry.animation_seconds = maxf(0.0, float(entry.animation_seconds) - step)
				if entry.animation_seconds <= 0.00001:
					if entry.stage == "slicing":
						entry.stage = "preparing"
						manager.transition_order(id, "preparing")
					else:
						entry.stage = "ready"
						manager.transition_order(id, "ready_to_serve")
		arrivals_elapsed += step
		if arrivals_elapsed >= float(rules.arrival_seconds) and _arrive():
			arrivals_elapsed = 0.0
		_check_end()
	changed.emit()


func current_food() -> Dictionary:
	return food.get(manager.selected_order_id, {}).duplicate(true)


func select_order(id: String) -> bool:
	if not can_interact() or not manager.select_order(id):
		return false
	changed.emit()
	return true


func navigate(destination: String) -> bool:
	if not can_interact() or destination not in ["order", "roast", "prepare"]:
		return false
	station = destination
	changed.emit()
	return true


func set_paused(value: bool) -> void:
	paused = value
	changed.emit()


func can_interact() -> bool:
	return not paused and rating.is_empty() and not summary_visible


func accept_current() -> bool:
	if not can_interact() or not manager.accept_order(manager.selected_order_id):
		return _reject("This ticket cannot be accepted again.")
	_notify("Order accepted. Go to Roast to begin.")
	return true


func oven_count() -> int:
	var count := 0
	for entry in food.values():
		if entry.stage == "roasting":
			count += 1
	return count


func action_available(number: int) -> bool:
	if not can_interact():
		return false
	var order := manager.get_order(manager.selected_order_id)
	var entry := current_food()
	if order.is_empty() or entry.is_empty() or order.status == "pending":
		return false
	if station == "roast":
		return (number == 1 and entry.stage == "waiting" and oven_count() < int(rules.oven_slots)) or (number == 2 and entry.stage == "roasting") or (number == 3 and entry.stage == "taken_out")
	if station == "prepare" and entry.stage == "preparing":
		if number == 0:
			return "duck_meat" in entry.ingredients
		return number >= 1 and number <= 5 and not rules.ingredient_actions[number - 1] in entry.ingredients
	return false


func perform_action(number: int) -> bool:
	if not action_available(number):
		return _reject("Action unavailable. Check acceptance, the current station and the ticket's progress.")
	var id := manager.selected_order_id
	var entry: Dictionary = food[id]
	if station == "roast":
		match number:
			1:
				if not manager.transition_order(id, "roasting"):
					return false
				entry.stage = "roasting"
				_notify("Duck placed in the oven. Take it out at 12–18 seconds.")
			2:
				entry.stage = "taken_out"
				entry.quality = roast_quality(float(entry.roast_seconds))
				_notify("Duck removed: %s. Use action 3 to slice it." % entry.quality)
			3:
				entry.stage = "slicing"
				entry.animation_seconds = float(rules.slice_seconds)
				_notify("Slicing duck…")
	else:
		if number == 0:
			entry.stage = "wrapping"
			entry.animation_seconds = float(rules.wrap_seconds)
			_notify("Rolling the wrap. Ingredients are now locked.")
		else:
			entry.ingredients.append(rules.ingredient_actions[number - 1])
			_notify("Added %s." % manager.catalog.ingredients[rules.ingredient_actions[number - 1]].en)
	changed.emit()
	return true


func remove_ingredient(ingredient: String) -> bool:
	var entry := current_food()
	if not can_interact() or station != "prepare" or entry.get("stage") != "preparing" or ingredient == "duck_meat" or ingredient not in entry.ingredients:
		return _reject("Only side ingredients can be removed, before rolling.")
	food[manager.selected_order_id].ingredients.erase(ingredient)
	_notify("Ingredient removed. You can add it again.")
	return true


func roast_quality(seconds: float) -> String:
	if seconds < float(rules.cooked_seconds):
		return "raw"
	return "cooked" if seconds < float(rules.burnt_seconds) else "burnt"


func serve_current() -> bool:
	var id := manager.selected_order_id
	if not can_interact() or food.get(id, {}).get("stage") != "ready":
		return _reject("Finish a valid wrap before serving.")
	var order := manager.get_order(id)
	if order.get("status") != "ready_to_serve":
		return _reject("This ticket is no longer available.")
	var required: Array = []
	for item in order.ingredients:
		required.append(item.id)
	var prep_score := 0
	for ingredient in rules.ingredient_actions:
		if (ingredient in required) == (ingredient in food[id].ingredients):
			prep_score += 20
	var wait_score := clampf(float(order.remaining_seconds) / float(rules.patience_seconds) * 100.0, 0, 100)
	var roast_score := int(rules.roast_scores[food[id].quality])
	var total := roundi((wait_score + roast_score + prep_score) / 3.0)
	var result := {"order_id": id, "customer_name": order.customer_name.duplicate(true), "order": order.duplicate(true), "ingredients": food[id].ingredients.duplicate(), "quality": food[id].quality, "wait_score": wait_score, "roast_score": roast_score, "prep_score": prep_score, "total": total, "reaction": "Happy" if total >= 90 else ("Satisfied" if total >= 70 else "Unhappy")}
	if not manager.transition_order(id, "served"):
		return false
	results.append(result)
	rating = result.duplicate(true)
	rating_elapsed = 0.0
	food.erase(id)
	_notify("Order served. Showing the three station scores.")
	return true


func can_return() -> bool:
	return not paused and not rating.is_empty() and rating_elapsed >= float(rules.rating_seconds)


func return_to_work() -> bool:
	if not can_return():
		return false
	rating.clear()
	rating_elapsed = 0.0
	station = "order"
	_check_end()
	changed.emit()
	return true


func summary() -> Dictionary:
	var sum := 0
	for result in results:
		sum += int(result.total)
	var average := float(sum) / results.size() if not results.is_empty() else 0.0
	return {"served": results.size(), "expired": created_count - results.size() - manager.get_visible_orders().size(), "total": sum, "average": average, "success": results.size() >= int(rules.target_served) and average >= float(rules.target_average)}


func _expire(id: String) -> void:
	food.erase(id)
	_notify("%s expired. Its oven slot, duck and wrap were cleared." % id)


func _check_end() -> void:
	summary_visible = created_count >= int(rules.shift_orders) and manager.get_visible_orders().is_empty() and rating.is_empty()


func _reject(reason: String) -> bool:
	_notify(reason)
	return false


func _notify(text: String) -> void:
	message = text
	feedback.emit(text)
	changed.emit()
