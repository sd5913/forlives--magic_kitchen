extends Control
## The workbench owns the order manager and advances the shift clock once.

const OrderManager = preload("res://scenes/orders/order_manager.gd")
const ROAST_SECONDS := 4.0
const DUCK := "duck_meat"

var manager := OrderManager.new()
var _paused := false
var _focused := true
var _served_count := 0
var _roasting: Dictionary = {}
var _fillings: Dictionary = {}
var _ingredient_ids: Array[String] = []
var _clock: Label
var _roast_button: Button
var _prep_button: Button
var _serve_button: Button
var _ingredient_picker: OptionButton
var _add_button: Button
var _reset_fillings_button: Button

@onready var _notice: Label = $ControlsHint


func _ready() -> void:
	manager.name = "OrderManager"
	add_child(manager)
	$OrderPanel.manager = manager
	$OrderPanel.station_opened.connect(_connect_station)
	manager.order_selected.connect(func(_id): _refresh())
	manager.order_updated.connect(func(_order): _refresh())
	manager.order_expired.connect(_on_expired)
	get_window().focus_entered.connect(func(): _focused = true)
	get_window().focus_exited.connect(func(): _focused = false)

	var oven := $Mortar
	oven.set_script(null)
	oven.get_node("Title").text = "Roast & prepare"
	oven.get_node("Status").queue_free()
	oven.get_node("InputCheck").queue_free()
	_clock = Label.new()
	_clock.position = Vector2(20, 66)
	oven.add_child(_clock)
	_roast_button = _button(oven, "Start roast", Vector2(20, 111), 290, _start_roast)
	_prep_button = _button(oven, "Finish roll", Vector2(20, 159), 290, _finish_roll)

	_ingredient_picker = OptionButton.new()
	_ingredient_picker.position = Vector2(10, 58)
	_ingredient_picker.size = Vector2(160, 34)
	_ingredient_picker.clip_text = true
	$IngredientStorage.add_child(_ingredient_picker)
	for entry in manager.catalog.get("ingredients", {}):
		var ingredient_id: String = entry
		if ingredient_id == DUCK:
			continue
		_ingredient_ids.append(ingredient_id)
		_ingredient_picker.add_item(manager.catalog["ingredients"][ingredient_id]["en"])
	_add_button = _button($IngredientStorage, "Add ingredient", Vector2(10, 104), 160, _add_ingredient)
	_reset_fillings_button = _button($IngredientStorage, "Clear ingredients", Vector2(10, 150), 160, _clear_ingredients)
	_serve_button = _button($DeliveryCounter, "Serve roll", Vector2(20, 57), 226, _serve_roll)
	_refresh()
	$OrderPanel._on_open_pressed()


func _process(delta: float) -> void:
	if _paused or not _focused:
		return
	manager.advance_time(delta)
	for id in _roasting.keys():
		_roasting[id] -= delta
		if _roasting[id] <= 0.0:
			_roasting.erase(id)
			if manager.transition_order(id, "preparing"):
				_notice.text = "%s roasted and sliced. Add the requested ingredients." % id
	_refresh_clock()


func _connect_station(station: Control) -> void:
	if station.workbench_requested.is_connected(_return_to_workbench):
		return
	station.workbench_requested.connect(_return_to_workbench)
	station.pause_requested.connect(_set_paused)
	station.restart_requested.connect(_confirm_restart)


func _return_to_workbench(zone: String) -> void:
	$OrderPanel._station.hide()
	# A paused shift can be resumed at the order station.
	if zone == "roast":
		_roast_button.grab_focus()
	else:
		_ingredient_picker.grab_focus()


func _set_paused(paused: bool) -> void:
	_paused = paused
	_notice.text = "Shift paused. Resume at the order station." if paused else "Shift resumed."
	_refresh()


func _confirm_restart() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Restart the shift?"
	dialog.dialog_text = "This clears all tickets, ingredients and served rolls."
	var was_paused := _paused
	_paused = true
	dialog.confirmed.connect(func():
		_roasting.clear()
		_fillings.clear()
		_served_count = 0
		manager.reset_orders()
		manager.create_order()
		_paused = was_paused
		_refresh()
		dialog.queue_free())
	dialog.canceled.connect(func():
		_paused = was_paused
		dialog.queue_free())
	add_child(dialog)
	dialog.popup_centered()


func _start_roast() -> void:
	if _paused:
		return
	var id := manager.selected_order_id
	if not _roasting.is_empty() or not manager.transition_order(id, "roasting"):
		return
	_roasting[id] = ROAST_SECONDS
	_notice.text = "%s is in the oven." % id
	_refresh()


func _add_ingredient() -> void:
	var order := manager.get_order(manager.selected_order_id)
	if _paused or order.get("status") != "preparing" or _ingredient_picker.selected < 0:
		return
	var id: String = order["order_id"]
	var ingredient_id := _ingredient_ids[_ingredient_picker.selected]
	var selection: Dictionary = _fillings.get(id, {})
	selection[ingredient_id] = int(selection.get(ingredient_id, 0)) + 1
	_fillings[id] = selection
	var parts := PackedStringArray()
	for chosen in selection:
		parts.append("%s ×%d" % [manager.catalog["ingredients"][chosen]["en"], selection[chosen]])
	_notice.text = "%s: %s" % [id, ", ".join(parts)]


func _clear_ingredients() -> void:
	if _paused:
		return
	_fillings.erase(manager.selected_order_id)
	_notice.text = "Ingredients cleared. Try the recipe again."


func _finish_roll() -> void:
	var order := manager.get_order(manager.selected_order_id)
	if _paused or order.get("status") != "preparing":
		return
	var id: String = order["order_id"]
	var required := {}
	for item in order["ingredients"]:
		if item["id"] != DUCK:
			required[item["id"]] = int(required.get(item["id"], 0)) + int(item["quantity"])
	if _fillings.get(id, {}) != required:
		_notice.text = "Ingredients do not match %s. Check the ticket or clear and retry." % id
		return
	if manager.transition_order(id, "ready_to_serve"):
		_fillings.erase(id)
		_notice.text = "%s is ready. Serve the roll at Delivery." % id


func _serve_roll() -> void:
	if _paused:
		return
	var id := manager.selected_order_id
	if manager.transition_order(id, "served"):
		_served_count += 1
		_notice.text = "%s delivered. Orders served: %d." % [id, _served_count]


func _on_expired(id: String) -> void:
	_roasting.erase(id)
	_fillings.erase(id)
	_notice.text = "%s expired. Any unfinished food was cleared." % id
	_refresh()


func _refresh() -> void:
	var order := manager.get_order(manager.selected_order_id)
	var status: String = order.get("status", "")
	_roast_button.disabled = _paused or status != "accepted" or not _roasting.is_empty()
	_prep_button.disabled = _paused or status != "preparing"
	_add_button.disabled = _prep_button.disabled
	_reset_fillings_button.disabled = _prep_button.disabled
	_serve_button.disabled = _paused or status != "ready_to_serve"
	_refresh_clock()


func _refresh_clock() -> void:
	var order := manager.get_order(manager.selected_order_id)
	if order.is_empty():
		_clock.text = "No active ticket"
		return
	var id: String = order["order_id"]
	var status: String = str(order["status"]).replace("_", " ").capitalize()
	var roast_time := float(_roasting.get(id, 0.0))
	if roast_time > 0.0:
		status = "Roasting %ds" % ceili(roast_time)
	_clock.text = "%s · %s · %ds left" % [id, status, ceili(order["remaining_seconds"])]


func _button(parent: Control, caption: String, position: Vector2, width: float, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.position = position
	button.size = Vector2(width, 36)
	button.pressed.connect(action)
	parent.add_child(button)
	return button
