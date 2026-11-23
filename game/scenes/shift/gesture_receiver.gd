extends Node
## Local-only raw finger counts. No camera frames or remote network access.
signal gesture_triggered(number: int)
signal status_changed(message: String)
const Gate = preload("res://scenes/shift/gesture_gate.gd")
var gate := Gate.new()
var peer := PacketPeerUDP.new()
var listening := false
var latest_number := -1
var age := 100.0
var camera_pid := -1
var status := "Camera off · use action cards or keyboard"
var enabled := true


func _ready() -> void:
	listening = peer.bind(4243, "127.0.0.1") == OK
	if not listening:
		_set_status("Camera port unavailable; mouse and keyboard remain available.")


func invalidate() -> void:
	gate.invalidate()


func _process(delta: float) -> void:
	age += delta
	var processed := 0
	while listening and peer.get_available_packet_count() > 0 and processed < 64:
		processed += 1
		var packet := peer.get_packet()
		if packet.size() > 1024:
			continue
		var data = JSON.parse_string(packet.get_string_from_utf8())
		if not data is Dictionary:
			continue
		if data.get("type") == "sample" and data.get("number") is float:
			var raw := float(data.number)
			if raw == floorf(raw) and raw >= -1 and raw <= 5:
				latest_number = int(raw)
				age = 0.0
		elif data.get("type") == "status":
			_set_status(str(data.get("message", "")))
	if age > 0.8:
		latest_number = -1
		if camera_pid > 0:
			_set_status("Camera signal lost · mouse and keyboard available")
	if not enabled:
		gate.invalidate()
		return
	var action := gate.sample(latest_number, minf(delta, 0.1))
	if action >= 0:
		gesture_triggered.emit(action)


func toggle_camera() -> void:
	if camera_pid > 0 and OS.is_process_running(camera_pid):
		OS.kill(camera_pid)
		camera_pid = -1
		latest_number = -1
		gate.invalidate()
		_set_status("Camera stopped · use action cards or keyboard")
		return
	if not listening:
		_set_status("Camera port unavailable")
		return
	var environment := ProjectSettings.globalize_path("res://../.venv-gesture")
	var python := environment.path_join("Scripts/python.exe" if OS.get_name() == "Windows" else "bin/python")
	var script := ProjectSettings.globalize_path("res://../tools/shift_camera.py")
	if not FileAccess.file_exists(python) or not FileAccess.file_exists(script):
		_set_status("Camera setup missing · see docs/technical/SHIFT-FLOW.md")
		return
	camera_pid = OS.create_process(python, PackedStringArray([script]))
	_set_status("Camera starting · allow access if prompted" if camera_pid > 0 else "Camera could not start")


func _set_status(text: String) -> void:
	if text != status:
		status = text
		status_changed.emit(status)


func _exit_tree() -> void:
	if camera_pid > 0 and OS.is_process_running(camera_pid):
		OS.kill(camera_pid)
	peer.close()
