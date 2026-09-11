extends RefCounted
## Install once per action; reloads must not duplicate mappings.
static func install() -> void:
	var buttons := {"interact": JOY_BUTTON_A, "attack": JOY_BUTTON_X, "restart": JOY_BUTTON_START,
		"ui_cancel": JOY_BUTTON_B, "mute": JOY_BUTTON_Y,
		"move_left": JOY_BUTTON_DPAD_LEFT, "move_right": JOY_BUTTON_DPAD_RIGHT,
		"move_up": JOY_BUTTON_DPAD_UP, "move_down": JOY_BUTTON_DPAD_DOWN}
	if not InputMap.has_action("mute"):
		InputMap.add_action("mute")
		var key := InputEventKey.new()
		key.physical_keycode = KEY_M
		InputMap.action_add_event("mute", key)
	for action in buttons:
		var event := InputEventJoypadButton.new()
		event.button_index = buttons[action]
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)
	var axes := {"move_left": [JOY_AXIS_LEFT_X, -1.0], "move_right": [JOY_AXIS_LEFT_X, 1.0],
		"move_up": [JOY_AXIS_LEFT_Y, -1.0], "move_down": [JOY_AXIS_LEFT_Y, 1.0]}
	for action in axes:
		var event := InputEventJoypadMotion.new()
		event.axis = axes[action][0]
		event.axis_value = axes[action][1]
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)
