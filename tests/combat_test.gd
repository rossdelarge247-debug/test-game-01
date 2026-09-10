extends SceneTree
## Integration checks against real hit areas, physics, input and scene resets.

var failures := 0
var checks := 0
var world: Node2D
var player: CharacterBody2D
var enemy: CharacterBody2D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await _fresh()
	_check(player.health == 5 and enemy.health == 3, "fresh health")
	for keycode in [KEY_J, KEY_SPACE]:
		var key := InputEventKey.new()
		key.physical_keycode = keycode
		_check(InputMap.action_has_event("attack", key), "attack key %d" % keycode)
	_check(world.get_node("HUD/Layout/AttackAnchor/Attack").action == "attack", "touch maps to same attack")
	_key(KEY_J, true)
	await _frames(2)
	_key(KEY_J, false)
	_check(player.swing_left > 0, "physical J starts sword swing")
	_check(not player.request_attack(), "cooldown prevents immediate repeat")
	await _frames(25)
	_check(player.swing_left == 0, "swing expires")
	_check(enemy.health == 3, "distant enemy not hit")

	for direction in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		await _fresh()
		player.facing = direction
		enemy.position = player.position + direction * 40
		await _frames(3)
		player.request_attack()
		await _frames(2)
		_check(enemy.health == 2, "sword hits facing %s" % direction)
		# Keep the hurtbox inside the swing to prove per-swing deduplication.
		enemy.knockback = Vector2.ZERO
		await _frames(6)
		_check(enemy.health == 2, "one damage per swing %s" % direction)

	await _fresh()
	player.facing = Vector2.LEFT
	enemy.position = player.position + Vector2(40, 0)
	await _frames(3)
	player.request_attack()
	await _frames(12)
	_check(enemy.health == 3, "sword cannot hit behind player")
	await _fresh()
	player.position = Vector2(294, 102)
	enemy.position = Vector2(343, 102)
	player.facing = Vector2.RIGHT
	await _frames(3)
	player.request_attack()
	await _frames(12)
	_check(enemy.health == 3, "wall blocks sword even when hurtbox is in range")

	await _fresh()
	enemy.position = player.position + Vector2(18, 0)
	await _frames(4)
	_check(player.health == 4, "real contact area damages player")
	_check(player.protection_left > 0, "damage starts protection")
	_check(not player.take_hit(1, Vector2.LEFT), "protection prevents damage stacking")
	_check(player.knockback.length() > 0, "damage applies knockback")
	enemy.position = Vector2(550, 180)
	await _frames(60)
	_check(player.take_hit(1, Vector2.LEFT), "damage resumes after protection expires")
	_check(world.get_node("HUD/Layout/Top/Health").text == "HEALTH  3 / 5", "health HUD follows damage")

	await _fresh()
	for i in range(3):
		enemy.position = player.position + Vector2(40, 0)
		enemy.knockback = Vector2.ZERO
		await _frames(3)
		player.request_attack()
		await _frames(23)
	_check(enemy.health == 0 and not enemy.visible, "three separate sword hits defeat enemy")
	_check(not player.combat_enabled, "victory stops combat")
	_check("Enemy defeated" in world.get_node("HUD/Layout/Message").text, "victory prompt")
	_check(not player.request_attack(), "no attacks after victory")
	await _restart()
	_check(player.health == 5 and enemy.health == 3 and enemy.visible, "restart after victory restores both actors")
	player.take_hit(5, Vector2.LEFT)
	await _frames(3)
	_check(player.health == 0 and enemy.stopped, "player defeat stops enemy")
	_check(not player.request_attack(), "dead player cannot attack")
	var at := player.position
	_key(KEY_D, true)
	await _frames(10)
	_key(KEY_D, false)
	_check(player.position.is_equal_approx(at), "dead player cannot move")
	_check("Try again" in world.get_node("HUD/Layout/Message").text, "defeat prompt")
	world.get_node("HUD/Layout/RestartTouch").emit_signal("pressed")
	await _frames(5)
	_bind()
	_check(player.health == 5 and enemy.health == 3, "touch restart after defeat restores health")

	_key(KEY_SPACE, true)
	await _frames(2)
	_check(player.swing_left > 0, "Space also attacks")
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _frames(2)
	_check(not player.has_focus and player.swing_left == 0, "focus loss cancels swing and movement")
	_check(not Input.is_action_pressed("attack"), "focus loss releases held attack")
	_check(not player.take_hit(1, Vector2.LEFT), "unfocused player is protected")
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_key(KEY_SPACE, false)
	await _frames(25)
	_check(player.swing_left == 0, "focus return does not resume held attack")
	_check(player.request_attack(), "new attack works after focus return")

	print("COMBAT_TESTS_PASSED checks=%d" % checks if failures == 0 else "COMBAT_TESTS_FAILED %d" % failures)
	quit(0 if failures == 0 else 1)


func _fresh() -> void:
	if is_instance_valid(world):
		world.queue_free()
		await process_frame
	world = load("res://scenes/gate2.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	_bind()
	enemy.move_speed = 0 # Hold targets still; browser tests use normal pursuit.
	await _frames(3)


func _bind() -> void:
	world = current_scene
	player = world.get_node("Acaciana")
	enemy = world.get_node("Enemy")


func _restart() -> void:
	_key(KEY_R, true)
	await _frames(5)
	_key(KEY_R, false)
	_bind()


func _key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)


func _frames(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame


func _check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)
