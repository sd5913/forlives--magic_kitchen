extends Node

## Receives local camera-gesture events from tools/gesture_camera.py over UDP.
const PORT := 4242

var station
var peer := PacketPeerUDP.new()
var listening := false


func _ready() -> void:
	var error := peer.bind(PORT, "127.0.0.1")
	listening = error == OK
	if listening:
		station.set_gesture_status("waiting for camera bridge on UDP %d" % PORT)
	else:
		station.set_gesture_status("camera port %d unavailable" % PORT)
	set_process(listening)


func _process(_delta: float) -> void:
	while peer.get_available_packet_count() > 0:
		var packet := peer.get_packet().get_string_from_utf8()
		var data = JSON.parse_string(packet)
		if not data is Dictionary:
			continue
		if data.get("type", "") == "status":
			station.set_gesture_status(str(data.get("message", "camera bridge connected")))
		elif data.get("type", "") == "gesture":
			var action := str(data.get("action", ""))
			var active := bool(data.get("active", false))
			if not action.is_empty():
				station.receive_action(action, active)
			station.set_gesture_status(str(data.get("label", action)))


func _exit_tree() -> void:
	if listening:
		peer.close()
