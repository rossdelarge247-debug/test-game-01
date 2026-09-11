extends SceneTree
var world: Node2D
var player: CharacterBody2D
var failures := 0
var checks := 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	world = load("res://scenes/gate5.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	player = world.get_node("Acaciana")
	world.get_node("Enemy").move_speed = 0
	await _frames(4)
	var start := player.position
	_axis(0.1)
	await _frames(8)
	_check(player.position.is_equal_approx(start), "stick deadzone prevents drift")
	_axis(1.0)
	await _frames(8)
	_axis(0.0)
	await _frames(3)
	_check(player.position.x > start.x + 10, "stick moves player")
	_check(world.input_mode == "gamepad", "stick selects controller prompts")
	_check("A" in world.get_node("HUD/Layout/Bottom/Controls").text, "controller use prompt shown")
	player.position = Vector2(315, 180)
	await _frames(3)
	_button(JOY_BUTTON_A, true)
	await _frames(3)
	_button(JOY_BUTTON_A, false)
	_check(player.sword_equipped, "controller A collects sword")
	_check(world.sounds.last_cue == "sword", "pickup plays its cue")
	_button(JOY_BUTTON_X, true)
	await _frames(2)
	_check(player.swing_left > 0, "controller X attacks")
	_button(JOY_BUTTON_X, false)
	_button(JOY_BUTTON_Y, true)
	await _frames(2)
	_button(JOY_BUTTON_Y, false)
	_check(world.sounds.muted, "controller Y mutes")
	var before: int = world.sounds.cue_count
	world.sounds.cue("memory")
	_check(world.sounds.cue_count == before, "mute suppresses cues")
	world._toggle_sound()
	for clip in world.sounds.clips.values():
		_check(clip.data.size() > 4000 and clip.mix_rate == 22050, "generated PCM cue has samples")
	world._change_room(1, Vector2(220, 180))
	_check(world.transition_left > 0 and not player.combat_enabled, "transition suspends player")
	_check(not world.interact(), "transition blocks interaction")
	world.get_node("Acaciana").notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var remaining: float = world.transition_left
	await _frames(5)
	_check(world.transition_left == remaining, "focus loss pauses transition")
	world.get_node("Acaciana").notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await _frames(28)
	_check(world.room == 1 and world.transition_left == 0 and player.combat_enabled, "transition completes and restores control")
	player.position = Vector2(330, 180)
	await _frames(3)
	_button(JOY_BUTTON_A, true)
	await _frames(3)
	_button(JOY_BUTTON_A, false)
	_check(world.passage_open and world.sounds.last_cue == "passage", "controller activates switch with cue")
	world._change_room(2, Vector2(400, 180))
	await _frames(28)
	_button(JOY_BUTTON_A, true)
	await _frames(3)
	_button(JOY_BUTTON_A, false)
	_check(world.popup_open and world.sounds.last_cue == "memory", "controller collects memory")
	_button(JOY_BUTTON_B, true)
	await _frames(3)
	_button(JOY_BUTTON_B, false)
	_check(not world.popup_open and player.combat_enabled, "controller B closes popup")
	player.position = Vector2(465, 180)
	await _frames(3)
	_button(JOY_BUTTON_A, true)
	await _frames(3)
	_button(JOY_BUTTON_A, false)
	_check(world.completed and world.sounds.last_cue == "finish", "controller completes route with cue")
	world._toggle_sound()
	_button(JOY_BUTTON_START, true)
	await _frames(6)
	_button(JOY_BUTTON_START, false)
	world = current_scene
	player = world.get_node("Acaciana")
	_check(world.room == 0 and not world.completed and not player.sword_equipped, "Menu restarts route")
	_check(world.sounds.muted, "mute preference survives restart")
	world._toggle_sound()
	_button(JOY_BUTTON_DPAD_LEFT, true)
	await _frames(6)
	var pos := player.position
	world._pad_connection(0, false)
	await _frames(6)
	_check(player.position.is_equal_approx(pos), "disconnect clears held movement")
	_button(JOY_BUTTON_DPAD_LEFT, false)
	_check(world.input_mode == "keyboard", "disconnect restores keyboard prompts")
	var count := InputMap.action_get_events("interact").size()
	world.PadControls.install()
	_check(InputMap.action_get_events("interact").size() == count, "reload does not duplicate mappings")
	print("PRESENTATION_TESTS_PASSED checks=%d" % checks if failures == 0 else "PRESENTATION_TESTS_FAILED")
	quit(0 if failures == 0 else 1)

func _frames(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame

func _axis(value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = JOY_AXIS_LEFT_X
	event.axis_value = value
	Input.parse_input_event(event)

func _button(index: int, pressed: bool) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = index
	event.pressed = pressed
	Input.parse_input_event(event)

func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)
