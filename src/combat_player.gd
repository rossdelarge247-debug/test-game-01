extends "res://src/player.gd"
## Gate 2 tuning is provisional; this sword has no canonical name.

signal health_changed(value: int)
signal defeated

const MAX_HEALTH := 5
const SWING_TIME := 0.16
const COOLDOWN := 0.34
const PROTECTION_TIME := 0.9

var health: int = MAX_HEALTH
var swing_left := 0.0
var cooldown_left := 0.0
var protection_left := 0.0
var attack_facing := Vector2.RIGHT
var hit_targets: Array[int] = []
var knockback := Vector2.ZERO
var combat_enabled := true
@onready var sword: CollisionShape2D = $Sword/Shape


func _ready() -> void:
	facing = Vector2.RIGHT


func _physics_process(delta: float) -> void:
	if not has_focus or health <= 0 or not combat_enabled:
		velocity = Vector2.ZERO
		return
	protection_left = maxf(0, protection_left - delta)
	cooldown_left = maxf(0, cooldown_left - delta)
	super._physics_process(delta)
	move_and_collide(knockback * delta)
	knockback = knockback.move_toward(Vector2.ZERO, 800 * delta)
	if Input.is_action_pressed("attack"):
		request_attack()
	if swing_left > 0:
		_hit_sword_targets()
		swing_left = maxf(0, swing_left - delta)
	queue_redraw()


func request_attack() -> bool:
	if cooldown_left > 0 or health <= 0 or not has_focus or not combat_enabled:
		return false
	attack_facing = facing
	$Sword.rotation = attack_facing.angle()
	swing_left = SWING_TIME
	cooldown_left = COOLDOWN
	hit_targets.clear()
	print("SWORD_SWING")
	return true


func _hit_sword_targets() -> void:
	# Query the actual sword shape during physics, avoiding stale overlap lists
	# on the first frame of a swing or when changing direction.
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = sword.shape
	query.transform = sword.global_transform
	query.collision_mask = 8
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var space := get_world_2d().direct_space_state
	for hit in space.intersect_shape(query):
		var target: Node2D = hit.collider.get_parent()
		var target_id: int = target.get_instance_id()
		if target_id in hit_targets:
			continue
		var ray := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1)
		if not space.intersect_ray(ray).is_empty():
			continue
		hit_targets.append(target_id)
		target.call("take_hit", 1, attack_facing)


func take_hit(amount: int, direction: Vector2) -> bool:
	if health <= 0 or protection_left > 0 or not has_focus or not combat_enabled:
		return false
	health = maxi(0, health - amount)
	protection_left = PROTECTION_TIME
	knockback = direction.normalized() * 140
	health_changed.emit(health)
	print("PLAYER_HIT health=%d" % health)
	if health == 0:
		swing_left = 0
		touch_direction = Vector2.ZERO
		knockback = Vector2.ZERO
		defeated.emit()
		print("PLAYER_DEFEATED")
	queue_redraw()
	return true


func stop_combat() -> void:
	combat_enabled = false
	swing_left = 0
	touch_direction = Vector2.ZERO
	velocity = Vector2.ZERO
	knockback = Vector2.ZERO
	queue_redraw()


func _notification(what: int) -> void:
	# Base player separately clears movement on focus loss.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		swing_left = 0
		knockback = Vector2.ZERO
		Input.action_release("attack")


func _draw() -> void:
	super._draw()
	if health == 0:
		draw_circle(Vector2.ZERO, 12, Color("7c8990"))
	elif protection_left > 0:
		draw_arc(Vector2.ZERO, 15, 0, TAU, 32, Color("ffb8b0"), 3, true)
	if swing_left > 0:
		var side := attack_facing.orthogonal()
		var tip := attack_facing * 44
		draw_colored_polygon(PackedVector2Array([
			attack_facing * 10 + side * 12, tip + side * 12,
			tip - side * 12, attack_facing * 10 - side * 12
		]), Color(0.8, 0.94, 1, 0.18))
		draw_line(attack_facing * 13, tip, Color("edfaff"), 5, true)
		draw_line(attack_facing * 17 - side * 8, attack_facing * 17 + side * 8, Color("e9c777"), 3, true)
