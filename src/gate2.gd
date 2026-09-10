extends Node2D
## One disposable arena. No implied location, enemy lore or sword identity.

const SOLIDS: Array[Rect2] = [
	Rect2(8, 62, 624, 8), Rect2(8, 312, 624, 8),
	Rect2(8, 70, 8, 242), Rect2(624, 70, 8, 242),
	Rect2(310, 80, 20, 44),
]


func _ready() -> void:
	for rect in SOLIDS:
		var wall := StaticBody2D.new()
		wall.position = rect.get_center()
		wall.collision_layer = 1
		wall.collision_mask = 6
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		wall.add_child(collision)
		$Walls.add_child(wall)
	$HUD/Layout/Top/Restart.pressed.connect(_request_restart)
	$HUD/Layout/RestartTouch.pressed.connect(_request_restart)
	$Acaciana.health_changed.connect(_health_changed)
	$Acaciana.defeated.connect(_player_defeated)
	$Enemy.defeated.connect(_enemy_defeated)
	var touch := DisplayServer.is_touchscreen_available()
	$HUD/Layout/RestartTouch.visible = touch
	$HUD/Layout/AttackAnchor.visible = touch
	$HUD/Layout/Top/Restart.visible = not touch
	if touch:
		$HUD/Layout/Bottom/Controls.text = "Drag to move · Hold ATTACK to swing · Best in landscape"
	_health_changed($Acaciana.health)
	print("GATE2_READY")


func _health_changed(value: int) -> void:
	$HUD/Layout/Top/Health.text = "HEALTH  %d / 5" % value


func _enemy_defeated() -> void:
	$Acaciana.stop_combat()
	$HUD/Layout/Message.text = "Enemy defeated · Restart to try again"


func _player_defeated() -> void:
	$Enemy.stopped = true
	$HUD/Layout/Message.text = "Try again · Tap Restart or press R"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_request_restart()


func _request_restart() -> void:
	_restart.call_deferred()


func _restart() -> void:
	Input.action_release("attack")
	var error := get_tree().reload_current_scene()
	if error != OK:
		push_error("Could not restart Gate 2: %s" % error_string(error))


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("24363c"))
	for x in range(16, 624, 24):
		draw_line(Vector2(x, 70), Vector2(x, 312), Color("2b3e43"))
	for y in range(72, 312, 24):
		draw_line(Vector2(16, y), Vector2(624, y), Color("2b3e43"))
	for rect in SOLIDS:
		draw_rect(rect, Color("71898b"))
