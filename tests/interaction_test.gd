extends SceneTree

var failures := 0
var checks := 0
var world: Node2D
var player: CharacterBody2D
var enemy: CharacterBody2D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await _fresh()
	_check(not player.sword_equipped, "starts without sword")
	_check(not player.request_attack(), "cannot attack before pickup")
	_check(not world.interact(), "cannot collect from outside reach")
	_check(not world.get_node("Pickups/Memory").available, "memory unavailable before fight")
	player.position = Vector2(312, 180)
	await _frames(3)
	_check(world.target == world.get_node("Pickups/SwordPickup"), "nearby sword becomes target")
	_check("Collect sword" in world.get_node("HUD/Layout/Bottom/Controls").text, "context prompt names action")
	_key(KEY_E, true)
	await _frames(2)
	_check(player.sword_equipped, "physical E equips sword")
	_check(world.get_node("Pickups/SwordPickup").collected, "pickup marked collected")
	_check(not world.get_node("Pickups/SwordPickup").visible, "collected item disappears")
	_check(player.request_attack(), "equipped sword attacks")
	await _frames(3)
	_check(world.memory_count == 0, "holding E does not collect another item")
	_key(KEY_E, false)
	_check(not world.interact(), "pickup cannot be repeated")
	_check("SWORD 1 / 1" in world.get_node("HUD/Layout/Top/Inventory").text, "item counter updates")
	await _frames(23)
	# Defeat the real enemy with the newly acquired weapon.
	for i in range(3):
		enemy.position = player.position + Vector2(40, 0)
		enemy.knockback = Vector2.ZERO
		await _frames(3)
		player.facing = Vector2.RIGHT
		player.request_attack()
		await _frames(23)
	_check(enemy.health == 0, "acquired sword defeats enemy")
	_check(player.combat_enabled, "combat victory leaves exploration available")
	_check(world.get_node("Pickups/Memory").visible, "victory reveals memory")
	_check(not world.interact(), "memory cannot be collected remotely")
	player.position = Vector2(398, 180)
	await _frames(3)
	_check(world.target == world.get_node("Pickups/Memory"), "nearby memory becomes target")
	_key(KEY_E, true)
	await _frames(3)
	_check(world.memory_count == 1 and world.popup_open, "E collects memory and opens popup")
	_check(not player.combat_enabled and enemy.stopped, "popup suspends actors")
	_check("CANON_TBD" in world.get_node("HUD/Layout/Popup/Body").text, "memory text leaves canon unresolved")
	_check(not world.interact(), "popup blocks collecting twice")
	_check(not player.take_hit(1, Vector2.LEFT), "player cannot be damaged while reading")
	var before := player.position
	_key(KEY_D, true)
	_key(KEY_J, true)
	await _frames(10)
	_check(player.position.is_equal_approx(before), "popup blocks movement")
	_check(player.swing_left == 0, "popup blocks sword swings")
	_key(KEY_E, false)
	world.get_node("HUD/Layout/Popup/Close").emit_signal("pressed")
	await _frames(3)
	_check(not world.popup_open and player.combat_enabled, "Continue restores control")
	_check(not Input.is_action_pressed("attack") and not Input.is_action_pressed("move_right"), "Continue clears held gameplay input")
	_key(KEY_D, false)
	_key(KEY_J, false)
	_check(not world.interact() and world.memory_count == 1, "memory remains single-use after popup")
	_check("test complete" in world.get_node("HUD/Layout/Message").text, "completion prompt")
	_key(KEY_R, true)
	await _frames(5)
	_key(KEY_R, false)
	_bind()
	_check(not player.sword_equipped and world.memory_count == 0, "restart clears inventory")
	_check(player.health == 5 and enemy.health == 3, "restart restores combat health")
	_check(world.get_node("Pickups/SwordPickup").visible and not world.get_node("Pickups/Memory").visible, "restart restores pickup availability")

	# Range and visibility are checked again at activation.
	enemy.move_speed = 0
	player.position = Vector2(298, 102)
	world.get_node("Pickups/SwordPickup").position = Vector2(338, 102)
	await _frames(3)
	_check(not world.interact(), "outside exact range cannot collect")
	world.get_node("Pickups/SwordPickup").position = Vector2(332, 102)
	await _frames(3)
	_check(not world.interact(), "wall blocks interaction within range")
	player.position = Vector2(312, 180)
	world.get_node("Pickups/SwordPickup").position = Vector2(340, 180)
	await _frames(3)
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not world.interact(), "focus loss blocks interaction")
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	player.take_hit(5, Vector2.LEFT)
	await _frames(2)
	_check(not world.interact(), "defeated player cannot collect")
	world.get_node("HUD/Layout/RestartTouch").emit_signal("pressed")
	await _frames(5)
	_bind()
	_check(player.health == 5 and not player.sword_equipped, "mobile restart after defeat restores initial state")
	_check(world.get_node("HUD/Layout/InteractAnchor/Use").action == "interact", "touch USE shares input action")

	print("INTERACTION_TESTS_PASSED checks=%d" % checks if failures == 0 else "INTERACTION_TESTS_FAILED %d" % failures)
	quit(0 if failures == 0 else 1)


func _fresh() -> void:
	world = load("res://scenes/gate3.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	_bind()
	enemy.move_speed = 0
	await _frames(3)


func _bind() -> void:
	world = current_scene
	player = world.get_node("Acaciana")
	enemy = world.get_node("Enemy")


func _frames(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame


func _key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)
