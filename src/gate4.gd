extends "res://src/gate3.gd"
## Provisional three-room route. Geometry and switch establish no story canon.

var room := 0
var passage_open := false
var completed := false
var barrier: StaticBody2D
const SWITCH_POSITION := Vector2(330, 180)
const END_POSITION := Vector2(465, 180)


func _ready() -> void:
	super._ready()
	barrier = StaticBody2D.new()
	barrier.collision_layer = 1
	barrier.collision_mask = 6
	for rect in [Rect2(382, 70, 16, 74), Rect2(382, 216, 16, 96), Rect2(382, 144, 16, 72)]:
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		collision.position = rect.get_center()
		barrier.add_child(collision)
	add_child(barrier)
	_sync_room()
	print("GATE4_READY")


func _physics_process(delta: float) -> void:
	if completed:
		return
	super._physics_process(delta)
	if popup_open or not $Acaciana.has_focus or $Acaciana.health <= 0:
		return
	var p: Vector2 = $Acaciana.position
	if p.y > 140 and p.y < 220:
		if p.x > 590 and room < 2 and $Enemy.health <= 0 and (room == 0 or passage_open):
			_change_room(room + 1, Vector2(220, 180))
		elif p.x < 50 and room > 0:
			_change_room(room - 1, Vector2(560, 180))


func _change_room(next: int, spawn: Vector2) -> void:
	room = next
	$Acaciana.stop_combat()
	_release_controls()
	$Acaciana.position = spawn
	$Acaciana.combat_enabled = true
	target = null
	_sync_room()
	print("ROOM_ENTERED room=%d" % room)


func _sync_room() -> void:
	$Enemy.visible = room == 0 and $Enemy.health > 0
	$Enemy.stopped = room != 0 or $Enemy.health <= 0
	$Pickups/SwordPickup.available = room == 0
	$Pickups/SwordPickup.visible = room == 0 and not $Pickups/SwordPickup.collected
	$Pickups/Memory.available = room == 2
	$Pickups/Memory.visible = room == 2 and not $Pickups/Memory.collected
	if is_instance_valid(barrier):
		for i in range(3):
			barrier.get_child(i).set_deferred("disabled", room != 1 or (i == 2 and passage_open))
	_refresh_ui()
	queue_redraw()


func _enemy_defeated() -> void:
	_sync_room()


func _near(point: Vector2) -> bool:
	if $Acaciana.position.distance_to(point) > 36.0:
		return false
	var ray := PhysicsRayQueryParameters2D.create($Acaciana.global_position, to_global(point), 1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()


func interact() -> bool:
	if completed or popup_open or not $Acaciana.has_focus or $Acaciana.health <= 0:
		return false
	if room == 1 and not passage_open and _near(SWITCH_POSITION):
		passage_open = true
		_sync_room()
		print("PASSAGE_OPENED")
		return true
	if room == 2 and memory_count == 1 and _near(END_POSITION):
		completed = true
		$Acaciana.stop_combat()
		_release_controls()
		_refresh_ui()
		print("SLICE_COMPLETED")
		return true
	return super.interact()


func close_popup() -> void:
	super.close_popup()
	_sync_room()


func _refresh_ui() -> void:
	super._refresh_ui()
	queue_redraw()
	$HUD/Layout/Top/Subtitle.text = ["Virginiana · 1/3 · Starting clearing", "Virginiana · 2/3 · Blocked passage", "Virginiana · 3/3 · Memory clearing"][room]
	var message: Label = $HUD/Layout/Message
	var controls: Label = $HUD/Layout/Bottom/Controls
	if completed:
		message.text = "Route complete · Restart to explore again"
		$HUD/Layout/TouchPad.hide()
		$HUD/Layout/AttackAnchor.hide()
		$HUD/Layout/InteractAnchor.hide()
		controls.text = "Virginiana greybox complete · Story and final artwork to follow"
	elif $Acaciana.health <= 0:
		message.text = "Try again · Restart restores the whole route"
	elif room == 0 and $Enemy.health <= 0:
		message.text = "Clearing safe · Follow the east arrow"
	elif room == 1:
		message.text = "Passage open · Continue east" if passage_open else "Find the switch to open the passage"
		if not passage_open and _near(SWITCH_POSITION):
			controls.text = ("Tap USE" if touch_enabled else "Press E") + " · Open passage"
			$HUD/Layout/InteractAnchor.modulate = Color.WHITE
	elif room == 2:
		message.text = "Memory recovered · Reach the ring marker" if memory_count > 0 else "Find and recover the memory fragment"
		if memory_count > 0 and _near(END_POSITION):
			controls.text = ("Tap USE" if touch_enabled else "Press E") + " · Finish route"
			$HUD/Layout/InteractAnchor.modulate = Color.WHITE


func _draw() -> void:
	super._draw()
	# Restrained map markers, all original greybox shapes.
	if room < 2:
		draw_line(Vector2(570, 180), Vector2(603, 180), Color("d9c88b"), 4)
		draw_line(Vector2(603, 180), Vector2(592, 169), Color("d9c88b"), 4)
		draw_line(Vector2(603, 180), Vector2(592, 191), Color("d9c88b"), 4)
	if room > 0:
		draw_line(Vector2(36, 180), Vector2(64, 180), Color("91b7b3"), 3)
		draw_line(Vector2(36, 180), Vector2(46, 170), Color("91b7b3"), 3)
	if room == 1:
		draw_rect(Rect2(382, 70, 16, 242), Color("486160") if passage_open else Color("ae8970"))
		if passage_open:
			draw_rect(Rect2(382, 144, 16, 72), Color("24363c"))
		draw_circle(SWITCH_POSITION, 16, Color("86bc9d") if passage_open else Color("e8bd69"))
		draw_line(SWITCH_POSITION + Vector2(0, 7), SWITCH_POSITION + Vector2(0, -9), Color("24363c"), 4)
	if room == 2:
		draw_arc(END_POSITION, 22, 0, TAU, 32, Color("86bc9d") if memory_count > 0 else Color("71898b"), 3)
		draw_circle(END_POSITION, 5, Color("d9c88b"))
