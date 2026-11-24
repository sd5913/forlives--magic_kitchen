extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size = Vector2i(1440, 900)
	var station = load("res://scenes/cooking_station/cooking_station_layered.tscn").instantiate()
	root.add_child(station)
	await process_frame
	await process_frame
	await process_frame
	var picture := root.get_texture().get_image()
	if picture != null:
		print("Screenshot: ", picture.get_size(), " ", picture.save_png("res://cooking_preview.png"))
	quit()
