extends SceneTree
var world: Node2D
var player: CharacterBody2D
var failures := 0
var checks := 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	await _fresh()
	# A controller may reconnect in a slot other than zero.
	var axis := InputEventJoypadMotion.new()
	axis.device = 2
	axis.axis = JOY_AXIS_LEFT_X
	axis.axis_value = -1.0
	var start := player.position
	Input.parse_input_event(axis)
	await _frames(8)
	axis.axis_value = 0.0
	Input.parse_input_event(axis)
	_check(player.position.x < start.x - 10, "controller slot 2 moves player")
	player.position = Vector2(315, 180)
	await _frames(3)
	var use := InputEventJoypadButton.new()
	use.device = 2
	use.button_index = JOY_BUTTON_A
	use.pressed = true
	Input.parse_input_event(use)
	await _frames(3)
	use.pressed = false
	Input.parse_input_event(use)
	_check(player.sword_equipped, "controller slot 2 collects sword")
	# Resize must clear a captured touch and an attack, even when the pad's
	# logical dimensions remain unchanged under canvas stretching.
	var pad = world.get_node("HUD/Layout/TouchPad")
	pad.finger = 3
	pad._update_direction(Vector2(142, 80))
	Input.action_press("attack")
	world.get_viewport().emit_signal("size_changed")
	_check(pad.finger == -1 and player.touch_direction == Vector2.ZERO, "viewport resize releases touch capture")
	_check(not Input.is_action_pressed("attack"), "viewport resize releases attack")
	# Restart during both halves of a room fade must discard its old state.
	for ticks in [3, 14]:
		world._change_room(1, Vector2(220, 180))
		await _frames(ticks)
		world.get_node("HUD/Layout/RestartTouch").emit_signal("pressed")
		await _frames(6)
		_bind()
		await _frames(30)
		_check(world.room == 0 and world.transition_left == 0 and player.combat_enabled, "restart discards pending room transition")
		_check(not world.curtain.visible and not world.passage_open, "restart clears curtain and passage")
	# Pause an active chase, not only an idle player.
	var enemy: CharacterBody2D = world.get_node("Enemy")
	enemy.position = player.position + Vector2(65, 0)
	enemy.active = true
	await _frames(4)
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	world.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var enemy_before := enemy.position
	var player_before := player.position
	var health_before: int = player.health
	Input.action_press("move_right")
	Input.action_press("attack")
	await _frames(20)
	_check(player.position.is_equal_approx(player_before) and enemy.position.is_equal_approx(enemy_before), "focus loss pauses player and chasing enemy")
	_check(player.health == health_before and not world.interact(), "focus loss blocks damage and interaction")
	world._release_controls()
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	world.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await _frames(4)
	_check(enemy.position.distance_to(enemy_before) > 0, "focus return resumes chase")
	# Full death and restart from the presented scene.
	player.protection_left = 0
	player.take_hit(5, Vector2.LEFT)
	await _frames(4)
	_check(player.health == 0 and not player.request_attack() and not world.interact(), "death blocks attack and use")
	world.get_node("HUD/Layout/RestartTouch").emit_signal("pressed")
	await _frames(6)
	_bind()
	_check(player.health == 5 and world.get_node("Enemy").health == 3, "restart after death restores both actors")
	# Popup restart, mute persistence, and backtracking across the animated route.
	world._toggle_sound()
	world._change_room(2, Vector2(400, 180))
	await _frames(28)
	_check(world.interact() and world.popup_open, "memory popup opens in presented scene")
	world._request_restart()
	await _frames(6)
	_bind()
	_check(not world.popup_open and world.memory_count == 0 and world.room == 0, "restart while reading clears popup and inventory")
	_check(world.sounds.muted, "mute survives popup restart")
	world._toggle_sound()
	world.passage_open = true
	world.memory_count = 1
	world.get_node("Pickups/Memory").collected = true
	world._change_room(2, Vector2(400, 180))
	await _frames(28)
	player.position = Vector2(40, 180)
	await _frames(30)
	_check(world.room == 1 and world.passage_open and world.memory_count == 1, "animated backtracking preserves progress")
	_check(not world.get_node("Pickups/Memory").visible, "backtracking does not reveal collected memory")
	print("QA_TESTS_PASSED checks=%d" % checks if failures == 0 else "QA_TESTS_FAILED")
	quit(0 if failures == 0 else 1)

func _fresh() -> void:
	world = load("res://scenes/gate5.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	_bind()
	await _frames(4)

func _bind() -> void:
	world = current_scene
	player = world.get_node("Acaciana")

func _frames(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame

func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)
