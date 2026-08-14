extends OptionButton

var options = [2, 1.0, 1.0, 0.5, 0.25]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_item_selected(index: int) -> void:
	var value = options[index]
	get_viewport().scaling_3d_scale = value
	if index == 0:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
	elif index == 1:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
	elif index == 2:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
	elif index >= 3:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
