extends Control
## A single captured finger controls movement; other fingers remain free for UI.

const RADIUS := 62.0
const DEAD_ZONE := 0.18

var finger: int = -1
var direction := Vector2.ZERO
@onready var player: CharacterBody2D = get_node("../../../Acaciana")


func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available()
	resized.connect(_release)
	if visible:
		print("TOUCH_CONTROLS_READY")


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.index == finger and (not event.pressed or event.canceled):
			_release()
		elif event.pressed and not event.canceled and finger == -1:
			var local := get_global_transform_with_canvas().affine_inverse() * event.position
			if local.distance_to(size * 0.5) <= size.x * 0.5:
				finger = event.index
				_update_direction(local)
	elif event is InputEventScreenDrag and event.index == finger:
		var local := get_global_transform_with_canvas().affine_inverse() * event.position
		_update_direction(local)


func _update_direction(local: Vector2) -> void:
	var offset := (local - size * 0.5) / RADIUS
	direction = Vector2.ZERO if offset.length() < DEAD_ZONE else offset.limit_length(1.0)
	player.set("touch_direction", direction)
	queue_redraw()


func _release() -> void:
	finger = -1
	direction = Vector2.ZERO
	if is_instance_valid(player):
		player.set("touch_direction", Vector2.ZERO)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_release()


func _exit_tree() -> void:
	_release()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, RADIUS + 12, Color(0.04, 0.08, 0.10, 0.9))
	draw_arc(center, RADIUS, 0, TAU, 64, Color("8da7a6"), 2, true)
	for axis in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var point: Vector2 = center + axis * 48.0
		var side: Vector2 = axis.orthogonal() * 5.0
		draw_polyline(PackedVector2Array([point - axis * 6.0 + side, point, point - axis * 6.0 - side]), Color("c1d7d3"), 2, true)
	draw_circle(center + direction * 40, 23, Color("e9c777"))
