extends SceneTree
## Exercise the actual scene, input map, physics and restart path in CI.

var failures: int = 0
var world: Node2D
var player: CharacterBody2D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	world = load("res://scenes/gate1.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	player = world.get_node("Acaciana")
	await _frames(3)
	_check(player.position.is_equal_approx(Vector2(192, 448)), "spawn is correct")
	for pair in [["move_left", KEY_A], ["move_left", KEY_LEFT],
		["move_right", KEY_D], ["move_right", KEY_RIGHT],
		["move_up", KEY_W], ["move_up", KEY_UP],
		["move_down", KEY_S], ["move_down", KEY_DOWN], ["restart", KEY_R]]:
		var key := InputEventKey.new()
		key.physical_keycode = pair[1]
		_check(InputMap.action_has_event(pair[0], key), "key binding: %s / %s" % pair)

	var start := player.position
	await _hold([KEY_D], 30)
	var cardinal_distance := player.position.distance_to(start)
	_check(absf(cardinal_distance - 80.0) < 6.0, "right movement at 160 units/sec")
	await _place(Vector2(192, 448))
	start = player.position
	await _hold([KEY_D, KEY_W], 30)
	_check(absf(player.position.distance_to(start) - cardinal_distance) < 6.0,
		"diagonal movement is no faster")
	_check(player.position.x > start.x and player.position.y < start.y, "diagonal direction")
	_check(player.get("facing") == Vector2.UP, "four-way facing on a diagonal")
	var stopped := player.position
	await _frames(10)
	_check(player.position.distance_to(stopped) < 0.1, "release stops movement without drift")

	# Four borders plus both sides of the internal partition.
	for trial in [
		[Vector2(80, 448), KEY_LEFT, 0, 42.0],
		[Vector2(1360, 448), KEY_RIGHT, 0, 1398.0],
		[Vector2(192, 80), KEY_UP, 1, 42.0],
		[Vector2(192, 816), KEY_DOWN, 1, 854.0],
		[Vector2(620, 300), KEY_RIGHT, 0, 662.0],
		[Vector2(756, 300), KEY_LEFT, 0, 714.0],
	]:
		await _place(trial[0])
		await _hold([trial[1]], 40)
		_check(absf(player.position[trial[2]] - trial[3]) < 1.0,
			"solid boundary at %s" % str(trial[0]))

	await _place(Vector2(280, 300))
	await _hold([KEY_D], 30)
	_check(absf(player.position.x - 310.0) < 1.0, "obstacle blocks movement")
	await _hold([KEY_D, KEY_S], 50)
	_check(player.position.y > 370 and player.position.x > 320, "slide around obstacle corner")

	await _place(Vector2(192, 448))
	await _hold([KEY_RIGHT], 384)
	_check(player.position.distance_to(Vector2(1216, 448)) < 8.0, "entire passage is traversable")
	await _frames(60)
	var camera: Camera2D = player.get_node("Camera2D")
	var center := camera.get_screen_center_position()
	_check(absf(center.x - 1120.0) < 2.0 and absf(center.y - 448.0) < 2.0,
		"camera follows and clamps to right boundary")
	await _hold([KEY_LEFT], 384)
	_check(player.position.distance_to(Vector2(192, 448)) < 12.0, "return route is traversable")

	_key(KEY_D, true)
	await _frames(5)
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	stopped = player.position
	await _frames(10)
	_check(player.position.distance_to(stopped) < 0.1, "focus loss stops motion")
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await _frames(5)
	_check(player.position.distance_to(stopped) < 0.1, "focus return does not retain held movement")
	_key(KEY_D, false)

	await _place(Vector2(900, 448))
	_key(KEY_R, true)
	await _frames(5)
	_key(KEY_R, false)
	world = current_scene
	player = world.get_node("Acaciana")
	_check(player.position.is_equal_approx(Vector2(192, 448)), "R reloads spawn")
	_check(player.get("facing") == Vector2.DOWN, "restart restores facing")
	await _place(Vector2(900, 448))
	world.get_node("HUD/Layout/Top/Restart").emit_signal("pressed")
	await _frames(5)
	player = current_scene.get_node("Acaciana")
	_check(player.position.is_equal_approx(Vector2(192, 448)), "button reloads spawn")

	if failures == 0:
		print("GATE1_TESTS_PASSED")
	else:
		push_error("Gate 1 failed %d checks" % failures)
	quit(0 if failures == 0 else 1)


func _place(at: Vector2) -> void:
	player.position = at
	player.velocity = Vector2.ZERO
	await _frames(3)


func _hold(keys: Array, frames: int) -> void:
	for code in keys:
		_key(code, true)
	await _frames(frames)
	for code in keys:
		_key(code, false)
	await _frames(1)


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
	if condition:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)
