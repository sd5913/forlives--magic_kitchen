extends RefCounted
## Require a neutral interval after every trigger and context change.
var stable_seconds := 0.5
var release_seconds := 0.25
var candidate := -1
var held_seconds := 0.0
var neutral_seconds := 0.0
var armed := true


func invalidate() -> void:
	armed = false
	candidate = -1
	held_seconds = 0.0
	neutral_seconds = 0.0


func sample(number: int, delta: float) -> int:
	if delta <= 0.0:
		return -1
	if number < 0 or number > 5:
		candidate = -1
		held_seconds = 0.0
		neutral_seconds += delta
		if neutral_seconds >= release_seconds:
			armed = true
		return -1
	neutral_seconds = 0.0
	if not armed:
		return -1
	if candidate != number:
		candidate = number
		held_seconds = 0.0
	held_seconds += delta
	if held_seconds + 0.00001 >= stable_seconds:
		armed = false
		return number
	return -1
