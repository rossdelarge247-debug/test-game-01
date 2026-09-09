extends Node2D
## Disposable movement course. No map layout or environmental lore is canon.

const WORLD_SIZE := Vector2(1440, 896)
const SOLIDS: Array[Rect2] = [
	Rect2(0, 0, 1440, 32),
	Rect2(0, 864, 1440, 32),
	Rect2(0, 32, 32, 832),
	Rect2(1408, 32, 32, 832),
	Rect2(672, 32, 32, 352),
	Rect2(672, 512, 32, 352),
	Rect2(320, 256, 128, 96),
	Rect2(384, 576, 160, 96),
	Rect2(928, 256, 128, 96),
	Rect2(992, 576, 160, 96),
]


func _ready() -> void:
	for rect in SOLIDS:
		var wall := StaticBody2D.new()
		wall.position = rect.get_center()
		wall.collision_layer = 1
		wall.collision_mask = 2
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		wall.add_child(collision)
		$Walls.add_child(wall)
	$HUD/Layout/Top/Restart.pressed.connect(_request_restart)
	$Acaciana/Camera2D.reset_smoothing()
	print("GATE1_READY")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_request_restart()


func _request_restart() -> void:
	_restart.call_deferred()


func _restart() -> void:
	var error := get_tree().reload_current_scene()
	if error != OK:
		push_error("Could not restart Gate 1: %s" % error_string(error))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("24363c"))
	for x in range(32, 1440, 32):
		draw_line(Vector2(x, 32), Vector2(x, 864), Color("2b3e43"))
	for y in range(32, 896, 32):
		draw_line(Vector2(32, y), Vector2(1408, y), Color("2b3e43"))
	# A quiet guide line helps first-time players find the passage.
	draw_line(Vector2(224, 448), Vector2(1184, 448), Color("527074"), 2.0)
	for x in [528, 688, 848]:
		draw_polyline(PackedVector2Array([
			Vector2(x - 6, 442), Vector2(x, 448), Vector2(x - 6, 454)
		]), Color("99bbb7"), 2.0)
	for rect in SOLIDS:
		draw_rect(rect, Color("4c6064"))
		draw_rect(rect.grow(-3), Color("566e71"), false, 1.0)
		draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), Color("8da7a6"), 2.0)
	draw_arc(Vector2(192, 448), 24, 0, TAU, 48, Color("e9c777"), 2.0, true)
	draw_arc(Vector2(1216, 448), 24, 0, TAU, 48, Color("92c9ba"), 2.0, true)
