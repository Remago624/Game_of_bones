extends SpinBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 60


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_value_changed(value: float) -> void:
	if value == 0:
		Engine.max_fps = 0
	else:
		Engine.max_fps = int(value)
