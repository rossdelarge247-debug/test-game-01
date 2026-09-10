extends TouchScreenButton


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 34, Color("93dfcd") if is_pressed() else Color("334c54"))
	draw_arc(Vector2.ZERO, 34, 0, TAU, 40, Color("93dfcd"), 2, true)
	draw_string(ThemeDB.fallback_font, Vector2(-16, 6), "USE", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffffff"))
