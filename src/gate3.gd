extends "res://src/gate2.gd"
## Gate 3 mechanics only; this room is not the later Virginiana slice.

var target: Area2D
var memory_count := 0
var popup_open := false
var touch_enabled := false


func _ready() -> void:
	super._ready()
	touch_enabled = DisplayServer.is_touchscreen_available()
	$HUD/Layout/Popup/Close.pressed.connect(close_popup)
	_refresh_ui()
	print("GATE3_READY")


func _physics_process(_delta: float) -> void:
	if not $Acaciana.has_focus:
		return
	if popup_open:
		if Input.is_action_just_pressed("interact"):
			close_popup()
		return
	target = _find_target()
	for pickup in $Pickups.get_children():
		pickup.highlighted = pickup == target
		pickup.queue_redraw()
	if Input.is_action_just_pressed("interact"):
		interact()
	_refresh_ui()


func _find_target() -> Area2D:
	if $Acaciana.health <= 0 or popup_open:
		return null
	var closest: Area2D = null
	var distance := INF
	for pickup in $Pickups.get_children():
		if not pickup.available or pickup.collected or not pickup.overlaps_body($Acaciana):
			continue
		var candidate_distance: float = $Acaciana.global_position.distance_to(pickup.global_position)
		if candidate_distance > 36.0:
			continue
		var ray := PhysicsRayQueryParameters2D.create($Acaciana.global_position, pickup.global_position, 1)
		if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		if candidate_distance < distance:
			closest = pickup
			distance = candidate_distance
	return closest


func interact() -> bool:
	if popup_open or not $Acaciana.has_focus or $Acaciana.health <= 0:
		return false
	# Recheck reach at activation, not just when the prompt was drawn.
	target = _find_target()
	if target == null or not target.collect():
		return false
	if target.kind == "sword":
		$Acaciana.sword_equipped = true
		print("SWORD_COLLECTED")
	else:
		memory_count += 1
		_open_memory()
		print("MEMORY_COLLECTED count=%d" % memory_count)
	target = null
	_refresh_ui()
	return true


func _enemy_defeated() -> void:
	# Unlike the combat-only gate, winning must leave movement available.
	$Pickups/Memory.reveal()
	_refresh_ui()


func _open_memory() -> void:
	popup_open = true
	$Acaciana.stop_combat()
	$Enemy.stopped = true
	_release_controls()
	$HUD/Layout/Popup.show()


func close_popup() -> void:
	if not popup_open:
		return
	popup_open = false
	$HUD/Layout/Popup.hide()
	_release_controls()
	$Acaciana.combat_enabled = $Acaciana.health > 0
	$Enemy.stopped = $Acaciana.health <= 0
	_refresh_ui()
	print("MEMORY_POPUP_CLOSED")


func _release_controls() -> void:
	$HUD/Layout/TouchPad._release()
	for action in ["move_left", "move_right", "move_up", "move_down", "attack", "interact"]:
		Input.action_release(action)


func _refresh_ui() -> void:
	$HUD/Layout/Top/Inventory.text = "SWORD %s   MEMORY %d / 1" % ["1 / 1" if $Acaciana.sword_equipped else "0 / 1", memory_count]
	$HUD/Layout/TouchPad.visible = touch_enabled and not popup_open
	$HUD/Layout/AttackAnchor.visible = touch_enabled and not popup_open and $Acaciana.sword_equipped
	$HUD/Layout/InteractAnchor.visible = touch_enabled and not popup_open
	$HUD/Layout/InteractAnchor.modulate = Color.WHITE if target != null else Color(0.6, 0.6, 0.6)
	$HUD/Layout/RestartTouch.visible = touch_enabled and not popup_open
	if $Acaciana.health <= 0:
		$HUD/Layout/Message.text = "Try again · Restart restores the items"
	elif memory_count > 0:
		$HUD/Layout/Message.text = "Memory recovered · Gate 3 test complete"
	elif not $Acaciana.sword_equipped:
		$HUD/Layout/Message.text = "Approach the sword and collect it"
	elif $Enemy.health > 0:
		$HUD/Layout/Message.text = "Sword equipped · Defeat the red enemy"
	else:
		$HUD/Layout/Message.text = "Approach the green memory fragment"
	var controls: Label = $HUD/Layout/Bottom/Controls
	if target != null:
		controls.text = "%s · %s" % ["Tap USE" if touch_enabled else "Press E", "Collect sword" if target.kind == "sword" else "Recover memory"]
	else:
		controls.text = "Drag to move · USE to collect · ATTACK to fight" if touch_enabled else "WASD / Arrows · Move    E · Use    J / Space · Attack    R · Restart"


func _unhandled_input(event: InputEvent) -> void:
	if popup_open and event.is_action_pressed("ui_cancel"):
		close_popup()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)


func _restart() -> void:
	_release_controls()
	super._restart()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Input.action_release("interact")
