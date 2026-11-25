extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size = Vector2i(1440, 900)
	var station = load("res://scenes/cooking_station/cooking_station_ui.tscn").instantiate()
	root.add_child(station)
	current_scene = station
	station.set_gesture_status("camera could not be opened")
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://_camera_status_temp.png")
	quit()
