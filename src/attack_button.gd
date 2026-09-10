extends TouchScreenButton
## Native multitouch button: an independent finger can attack while moving.


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 44, Color("e9c777") if is_pressed() else Color("334c54"))
	draw_arc(Vector2.ZERO, 44, 0, TAU, 48, Color("e9c777"), 2, true)
	draw_string(ThemeDB.fallback_font, Vector2(-32, 6), "ATTACK", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffffff"))
