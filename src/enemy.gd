extends CharacterBody2D
## Abstract pursuer. Identity, appearance and numerical tuning are provisional.

signal defeated
@export var move_speed := 48.0
var health := 3
var active := false
var stopped := false
var stun_left := 0.0
var knockback := Vector2.ZERO
@onready var player: CharacterBody2D = get_node("../Acaciana")


func _physics_process(delta: float) -> void:
	if health <= 0 or stopped or not player.has_focus or player.health <= 0:
		return
	var difference: Vector2 = player.global_position - global_position
	if difference.length() < 110:
		active = true
	stun_left = maxf(0, stun_left - delta)
	velocity = knockback
	if active and stun_left <= 0:
		velocity += difference.normalized() * move_speed
	move_and_slide()
	knockback = knockback.move_toward(Vector2.ZERO, 600 * delta)
	if stun_left <= 0:
		for area in $Contact.get_overlapping_areas():
			var direction: Vector2 = player.global_position - global_position
			if direction.is_zero_approx():
				direction = Vector2.LEFT
			area.get_parent().take_hit(1, direction)
	queue_redraw()


func take_hit(amount: int, direction: Vector2) -> void:
	if health <= 0 or stopped:
		return
	health = maxi(0, health - amount)
	stun_left = 0.25
	knockback = direction.normalized() * 110
	active = true
	print("ENEMY_HIT health=%d" % health)
	if health == 0:
		defeated.emit()
		print("ENEMY_DEFEATED")
		hide()
		$Hurtbox.set_deferred("monitorable", false)
	queue_redraw()


func _draw() -> void:
	var color := Color("e18c87") if stun_left <= 0 else Color("ffffff")
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -13), Vector2(13, 0), Vector2(0, 13), Vector2(-13, 0)
	]), color)
	for i in range(3):
		draw_rect(Rect2(-12 + i * 9, -22, 7, 3), Color("e9c777") if i < health else Color("4c6064"))
