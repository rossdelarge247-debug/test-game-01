extends Control


func _ready() -> void:
	var version := Engine.get_version_info()
	var version_label := str(version.get("string", "unknown"))
	$Center/Content/Status.text = "Godot %s • GDScript • Compatibility renderer" % version_label
	print("SMOKE_TEST_READY: Godot %s" % version_label)

