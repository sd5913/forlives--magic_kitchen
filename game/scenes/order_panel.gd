extends Panel
## Preserve the shared workbench footprint; expand our station on demand.

const Station = preload("res://scenes/orders/order_station.tscn")
signal station_opened(station: Control)

var manager: Node
var _layer: CanvasLayer
var _station: Control


func _on_open_pressed() -> void:
	if is_instance_valid(_station):
		_station.show()
		station_opened.emit(_station)
		return
	_layer = CanvasLayer.new()
	_layer.layer = 20
	add_child(_layer)
	_station = Station.instantiate()
	_station.embedded = true
	_station.manager = manager
	_layer.add_child(_station)
	_station.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_station.close_requested.connect(func():
		_station.hide())
	station_opened.emit(_station)
