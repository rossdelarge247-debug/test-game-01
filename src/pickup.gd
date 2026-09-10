extends Area2D
## Disposable item/memory symbols, without canonical design or item identity.

@export_enum("sword", "memory") var kind := "sword"
@export var available := true
var collected := false
var highlighted := false


func _ready() -> void:
	visible = available


func collect() -> bool:
	if not available or collected:
		return false
	collected = true
	hide()
	return true


func reveal() -> void:
	available = true
	show()


func _draw() -> void:
	var color := Color("e9c777") if kind == "sword" else Color("93dfcd")
	draw_circle(Vector2.ZERO, 15, Color("14282e"))
	draw_arc(Vector2.ZERO, 18 if highlighted else 15, 0, TAU, 40, color, 2, true)
	if kind == "sword":
		draw_line(Vector2(0, 8), Vector2(0, -10), Color("edfaff"), 4, true)
		draw_line(Vector2(-6, 3), Vector2(6, 3), color, 3, true)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(0, -10), Vector2(8, 0), Vector2(0, 10), Vector2(-8, 0)]), color)
