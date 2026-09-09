extends CharacterBody2D
## Gate 1 placeholder. Appearance and movement tuning are provisional.

@export var move_speed: float = 160.0

var facing := Vector2.DOWN
var has_focus := true


func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	if has_focus:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		# Diagonal motion keeps a cardinal facing; vertical wins equal-axis ties.
		if absf(direction.x) > absf(direction.y):
			facing = Vector2(signf(direction.x), 0.0)
		else:
			facing = Vector2(0.0, signf(direction.y))
	velocity = direction * move_speed
	move_and_slide()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		has_focus = false
		velocity = Vector2.ZERO
		for action in ["move_left", "move_right", "move_up", "move_down"]:
			Input.action_release(action)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		has_focus = true


func _draw() -> void:
	# Abstract marker, not a proposed character costume or canonical design.
	draw_circle(Vector2(0, 3), 12.0, Color("17272d"))
	draw_circle(Vector2.ZERO, 10.0, Color("e9c777"))
	draw_arc(Vector2.ZERO, 10.0, 0.0, TAU, 32, Color("fff0c3"), 1.5, true)
	var side := facing.orthogonal()
	draw_colored_polygon(PackedVector2Array([
		facing * 8.0, facing * 1.0 + side * 4.0, facing * 1.0 - side * 4.0
	]), Color("293b40"))
