extends Control

var kind := "wrap"
var ingredients: Array[String] = []
var rolled := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var center := size / 2.0
	var scale_factor := minf(size.x, size.y) / 100.0
	draw_set_transform(center, 0.0, Vector2.ONE * scale_factor)
	if kind == "wrap":
		_draw_wrap()
	else:
		_draw_food(kind, Vector2.ZERO, 1.0)


func _draw_wrap() -> void:
	if rolled:
		draw_circle(Vector2.ZERO, 46, Color("d9d0b3"))
		draw_circle(Vector2.ZERO, 41, Color("f6ebce"))
		draw_set_transform(Vector2(size.x / 2, size.y / 2), -0.35, Vector2.ONE * minf(size.x, size.y) / 100.0)
		draw_rect(Rect2(-27, -15, 54, 30), Color("d9aa6b"))
		draw_rect(Rect2(-24, -12, 48, 24), Color("f7dcaa"))
		draw_circle(Vector2(-24, 0), 12, Color("b56c3b"))
		draw_circle(Vector2(-24, 0), 8, Color("e7c187"))
		draw_circle(Vector2(-24, 0), 4, Color("789b53"))
		return
	draw_circle(Vector2.ZERO, 47, Color("b8c6c2"))
	draw_circle(Vector2.ZERO, 43, Color("f7f4df"))
	draw_circle(Vector2.ZERO, 38, Color("deb880"))
	draw_circle(Vector2.ZERO, 36, Color("f4ddad"))
	for i in range(12):
		var angle := float(i) * 2.4
		var radius := 8.0 + float(i % 4) * 7.0
		draw_circle(Vector2(cos(angle), sin(angle)) * radius, 0.8, Color("d4ac77"))
	for i in range(ingredients.size()):
		var offset := Vector2(-14 + (i % 2) * 27, -12 + (i / 2) * 17)
		_draw_food(ingredients[i], offset, 0.4)


func _draw_food(food: String, at: Vector2, amount: float) -> void:
	match food:
		"duck":
			for i in range(4):
				var p := at + Vector2((i - 1.5) * 8, 0) * amount
				draw_circle(p, 14 * amount, Color("883d21"))
				draw_circle(p + Vector2(0, 2) * amount, 11 * amount, Color("e7b98a"))
		"cucumber", "scallion", "radish":
			var color := Color("83a64b") if food == "cucumber" else Color("e6e3c2") if food == "scallion" else Color("bdc864")
			for i in range(6):
				var start := at + Vector2(-22, -12 + i * 5) * amount
				draw_line(start, start + Vector2(42, -8) * amount, color, 4.0 * amount, true)
		"sauce":
			draw_circle(at, 21 * amount, Color("e8e0ca"))
			draw_circle(at, 16 * amount, Color("63301e"))
			draw_arc(at, 9 * amount, 0.3, 4.2, 20, Color("a3673c"), 2 * amount, true)
