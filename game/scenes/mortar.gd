extends Panel

@onready var status: Label = $Status


func _on_input_check_toggled(active: bool) -> void:
	status.text = "Input status: active" if active else "Input status: idle"
