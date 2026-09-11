extends "res://src/gate4.gd"
## Lightweight original presentation over the accepted route, with unchanged canon.
const PadControls = preload("res://src/gamepad_controls.gd")
const Sounds = preload("res://src/sound_cues.gd")
const ROOM_NAMES := ["Starting clearing", "Blocked passage", "Memory clearing"]
var sounds: Node
var sound_button: Button
var curtain: ColorRect
var transition_label: Label
var transition_left := 0.0
var next_room := 0
var next_spawn := Vector2.ZERO
var swapped := false
var input_mode := "keyboard"
var previous_health := 5

func _ready() -> void:
	PadControls.install()
	super._ready()
	sounds = Sounds.new()
	add_child(sounds)
	sound_button = Button.new()
	sound_button.position = Vector2(206, 8)
	sound_button.size = Vector2(100, 28)
	sound_button.focus_mode = Control.FOCUS_NONE
	sound_button.add_theme_font_size_override("font_size", 12)
	sound_button.pressed.connect(_toggle_sound)
	$HUD/Layout.add_child(sound_button)
	curtain = ColorRect.new()
	curtain.size = Vector2(640, 360)
	curtain.color = Color(0.035, 0.07, 0.075, 0.0)
	curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	curtain.hide()
	$HUD/Layout.add_child(curtain)
	transition_label = Label.new()
	transition_label.position = Vector2(48, 148)
	transition_label.size = Vector2(544, 64)
	transition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	transition_label.add_theme_font_size_override("font_size", 24)
	curtain.add_child(transition_label)
	$HUD/Layout/Top.color = Color("132e30")
	$HUD/Layout/Bottom.color = Color("132e30")
	$HUD/Layout/Bottom/Controls.add_theme_font_size_override("font_size", 12)
	var plate := ColorRect.new()
	plate.position = Vector2(180, 278)
	plate.size = Vector2(300, 31)
	plate.color = Color(0.035, 0.09, 0.09, 0.9)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD/Layout.add_child(plate)
	$HUD/Layout.move_child(plate, $HUD/Layout/Message.get_index())
	Input.joy_connection_changed.connect(_pad_connection)
	if touch_enabled:
		input_mode = "touch"
	_refresh_ui()
	print("GATE5_READY")

func _input(event: InputEvent) -> void:
	var old_mode := input_mode
	if event is InputEventJoypadButton and event.pressed or event is InputEventJoypadMotion and absf(event.axis_value) > 0.25:
		if input_mode != "gamepad":
			input_mode = "gamepad"
			print("INPUT_MODE gamepad")
	elif event is InputEventKey and event.pressed:
		input_mode = "keyboard"
	elif event is InputEventScreenTouch and event.pressed:
		input_mode = "touch"
	if old_mode != input_mode:
		_refresh_ui()
	if event.is_action_pressed("mute") and not event.is_echo() and $Acaciana.has_focus:
		_toggle_sound()
		get_viewport().set_input_as_handled()

func _pad_connection(_device: int, connected: bool) -> void:
	if not connected:
		_release_controls()
		$Acaciana.velocity = Vector2.ZERO
		$Acaciana.swing_left = 0
		input_mode = "touch" if touch_enabled else "keyboard"
		_refresh_ui()
		print("GAMEPAD_DISCONNECTED")

func _toggle_sound() -> void:
	if is_instance_valid(sounds):
		sounds.toggle()
		_refresh_ui()

func _physics_process(delta: float) -> void:
	if not $Acaciana.has_focus:
		return
	if transition_left > 0:
		transition_left = maxf(0.0, transition_left - delta)
		if transition_left <= 0.18 and not swapped:
			swapped = true
			super._change_room(next_room, next_spawn)
			$Acaciana.stop_combat()
		if is_instance_valid(curtain):
			curtain.modulate.a = 1.0 - absf(transition_left - 0.18) / 0.18
		if transition_left == 0:
			_release_controls()
			$Acaciana.combat_enabled = $Acaciana.health > 0
			curtain.hide()
			_refresh_ui()
			print("TRANSITION_FINISHED room=%d" % room)
		return
	super._physics_process(delta)

func _change_room(next: int, spawn: Vector2) -> void:
	if transition_left > 0:
		return
	next_room = next
	next_spawn = spawn
	swapped = false
	transition_left = 0.36
	$Acaciana.stop_combat()
	_release_controls()
	transition_label.text = ROOM_NAMES[next]
	curtain.color.a = 1.0
	curtain.modulate.a = 0.0
	curtain.show()
	sounds.cue("room")

func interact() -> bool:
	if transition_left > 0:
		return false
	var had_sword: bool = $Acaciana.sword_equipped
	var had_passage := passage_open
	var had_memory := memory_count
	var result := super.interact()
	if result and is_instance_valid(sounds):
		if completed:
			sounds.cue("finish")
		elif memory_count > had_memory:
			sounds.cue("memory")
		elif passage_open and not had_passage:
			sounds.cue("passage")
		elif $Acaciana.sword_equipped and not had_sword:
			sounds.cue("sword")
	return result

func _health_changed(value: int) -> void:
	super._health_changed(value)
	if value < previous_health and is_instance_valid(sounds):
		sounds.cue("hurt")
	previous_health = value

func _enemy_defeated() -> void:
	super._enemy_defeated()
	if is_instance_valid(sounds):
		sounds.cue("defeat")

func _refresh_ui() -> void:
	super._refresh_ui()
	if is_instance_valid(sound_button):
		sound_button.text = "Sound: Off" if sounds.muted else "Sound: On"
		sound_button.visible = not popup_open and transition_left <= 0
	if input_mode == "gamepad":
		var controls: Label = $HUD/Layout/Bottom/Controls
		controls.text = controls.text.replace("Press E", "A").replace("Tap USE", "A")
		if target == null and not (room == 1 and not passage_open and _near(SWITCH_POSITION)) and not (room == 2 and memory_count > 0 and _near(END_POSITION)) and not completed:
			controls.text = "Stick/D-pad: Move · A: Use · X: Attack · Menu: Restart · Y: Sound"
		$HUD/Layout/Popup/Close.text = "Continue [A / B]"
	else:
		$HUD/Layout/Popup/Close.text = "Continue"
	if completed:
		$HUD/Layout/Message.text = "Route complete · Well done!"
		$HUD/Layout/Bottom/Controls.text = "Menu: Restart · Y: Sound" if input_mode == "gamepad" else "Restart to play again · Sound can be turned off above"

func _unhandled_input(event: InputEvent) -> void:
	if not $Acaciana.has_focus:
		return
	super._unhandled_input(event)

func _notification(what: int) -> void:
	super._notification(what)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(sounds):
		sounds.stop_all()

func _draw() -> void:
	var ground: Color = [Color("355747"), Color("3d4e53"), Color("305755")][room]
	draw_rect(Rect2(0, 0, 640, 360), ground)
	# Deterministic grass/stone marks stay away from the central walking path.
	for x in range(24, 618, 19):
		for y in range(80, 302, 21):
			if y < 144 or y > 216:
				var p := Vector2(x + (y % 7), y)
				draw_line(p, p + Vector2(2, -4), ground.lightened(0.10), 1)
	draw_rect(Rect2(16, 149, 608, 62), Color("8b8063") if room == 0 else Color("607b70"))
	for x in range(24, 624, 32):
		draw_line(Vector2(x, 158), Vector2(x + 10, 158), Color(1, 1, 1, 0.09), 1)
	for rect in SOLIDS:
		draw_rect(rect, Color("1c3636"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 3)), Color("719184"))
	var font := ThemeDB.fallback_font
	if room < 2:
		draw_line(Vector2(579, 180), Vector2(607, 180), Color("ffe4a3"), 4)
		draw_line(Vector2(607, 180), Vector2(597, 170), Color("ffe4a3"), 4)
		draw_line(Vector2(607, 180), Vector2(597, 190), Color("ffe4a3"), 4)
	if room > 0:
		draw_line(Vector2(34, 180), Vector2(62, 180), Color("c0d8cc"), 3)
		draw_line(Vector2(34, 180), Vector2(44, 170), Color("c0d8cc"), 3)
	if room == 0 and not $Acaciana.sword_equipped:
		draw_string(font, Vector2(321, 151), "SWORD", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ffedb9"))
	if room == 1:
		draw_rect(Rect2(382, 70, 16, 242), Color("233a3a"))
		if passage_open:
			draw_rect(Rect2(382, 144, 16, 72), Color("607b70"))
		else:
			for y in range(145, 215, 12):
				draw_rect(Rect2(382, y, 16, 7), Color("c49d66"))
		draw_circle(SWITCH_POSITION + Vector2(0, 3), 18, Color("1c3636"))
		draw_circle(SWITCH_POSITION, 14, Color("97d6b0") if passage_open else Color("f1c66e"))
		draw_line(SWITCH_POSITION + Vector2(-5, 6), SWITCH_POSITION + Vector2(6, -7), Color("23423c"), 4)
		draw_string(font, Vector2(309, 149), "OPEN" if passage_open else "SWITCH", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ffedb9"))
	if room == 2:
		if memory_count == 0:
			draw_string(font, Vector2(393, 150), "MEMORY", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("c0f0de"))
		draw_arc(END_POSITION, 22, 0, TAU, 32, Color("b6efd4") if memory_count > 0 else Color("86a49a"), 3)
		draw_circle(END_POSITION, 5, Color("ffe4a3"))
		draw_string(font, END_POSITION + Vector2(-19, 38), "FINISH", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ffedb9"))
