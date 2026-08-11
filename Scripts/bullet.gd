extends Node3D


const velocity = 80.0
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
var hit = false










# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var old_pos = global_position
	
	position += transform.basis * Vector3(0, 0, -velocity) * delta
	
	var new_pos = global_position
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(old_pos, new_pos)
	query.exclude = [self]
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 2 | 8
	
	var result = space_state.intersect_ray(query)
	var collider = result.get("collider")
	  #ray.is_colliding()
	if result and !hit:
		hit = true
		set_process(false)
		mesh.visible = false
		particles.emitting = true
		ray.enabled = false
		if collider.is_in_group("enemy"):
			collider.hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_bullet_delete_timeout() -> void:
	queue_free()
