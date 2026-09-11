extends SceneTree
var world: Node2D
var player: CharacterBody2D
var failures := 0
var checks := 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	world = load("res://scenes/gate4.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	player = world.get_node("Acaciana")
	var enemy: CharacterBody2D = world.get_node("Enemy")
	enemy.move_speed = 0
	await _frames(4)
	_check(world.room == 0 and not player.sword_equipped, "starts in clearing without sword")
	player.position = Vector2(601, 180)
	await _frames(4)
	_check(world.room == 0, "enemy blocks route progression")
	player.position = Vector2(315, 180)
	await _frames(4)
	_check(world.interact() and player.sword_equipped, "collect sword")
	for i in range(3):
		enemy.position = player.position + Vector2(40, 0)
		enemy.knockback = Vector2.ZERO
		await _frames(3)
		player.facing = Vector2.RIGHT
		player.request_attack()
		await _frames(25)
	_check(enemy.health == 0, "real sword defeats enemy")
	_check(not world.get_node("Pickups/Memory").available, "memory stays in later clearing")
	player.position = Vector2(601, 180)
	await _frames(5)
	_check(world.room == 1, "east exit enters passage")
	_check(player.sword_equipped, "inventory persists between rooms")
	_check(not world.interact(), "remote switch cannot activate")
	player.position = Vector2(360, 180)
	Input.action_press("move_right")
	await _frames(30)
	Input.action_release("move_right")
	_check(player.position.x < 382, "closed passage physically blocks movement")
	player.position = Vector2(330, 180)
	await _frames(3)
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not world.interact(), "unfocused player cannot open passage")
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(world.interact() and world.passage_open, "nearby switch opens passage")
	_check(not world.interact(), "switch is single use")
	await _frames(3)
	player.position = Vector2(360, 180)
	Input.action_press("move_right")
	await _frames(30)
	Input.action_release("move_right")
	_check(player.position.x > 398, "opened passage can be crossed")
	player.position = Vector2(601, 180)
	await _frames(5)
	_check(world.room == 2, "route enters memory clearing")
	_check(world.get_node("Pickups/Memory").visible, "memory appears in its room")
	player.position = Vector2(465, 180)
	await _frames(3)
	_check(not world.interact() and not world.completed, "endpoint requires memory")
	player.position = Vector2(400, 180)
	await _frames(3)
	_check(world.interact() and world.popup_open, "memory opens reading popup")
	player.position = Vector2(40, 180)
	await _frames(4)
	_check(world.room == 2 and not world.interact(), "popup blocks transition and completion")
	world.close_popup()
	await _frames(5)
	_check(world.room == 1 and world.passage_open and world.memory_count == 1, "backtracking preserves memory and switch")
	player.position = Vector2(40, 180)
	await _frames(5)
	_check(world.room == 0 and enemy.health == 0, "backtracking preserves enemy defeat")
	_check(not world.get_node("Pickups/SwordPickup").visible, "backtracking does not respawn sword")
	player.position = Vector2(601, 180)
	await _frames(5)
	player.position = Vector2(601, 180)
	await _frames(5)
	_check(world.room == 2 and not world.get_node("Pickups/Memory").visible, "memory does not respawn")
	player.position = Vector2(465, 180)
	await _frames(3)
	_check(world.interact() and world.completed, "endpoint completes route after memory")
	_check(not player.request_attack() and not world.interact(), "completion stops combat and duplicate activation")
	world.get_node("HUD/Layout/RestartTouch").emit_signal("pressed")
	await _frames(6)
	world = current_scene
	player = world.get_node("Acaciana")
	_check(world.room == 0 and not world.passage_open and not world.completed, "restart restores route progression")
	_check(player.health == 5 and not player.sword_equipped and world.memory_count == 0, "restart restores health and inventory")
	player.take_hit(5, Vector2.LEFT)
	player.position = Vector2(601, 180)
	await _frames(4)
	_check(world.room == 0 and not world.interact(), "death blocks traversal and interaction")
	print("SLICE_TESTS_PASSED checks=%d" % checks if failures == 0 else "SLICE_TESTS_FAILED")
	quit(0 if failures == 0 else 1)

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
