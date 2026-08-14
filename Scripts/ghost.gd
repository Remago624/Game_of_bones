extends CharacterBody3D
@export var player_path := "/root/world/NavigationRegion3D/Player"
const attack_range = 2.0
const sprint_range = 8.0
var health = 200
@onready var new_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
var state
var player = null
var speed = 5
@onready var healthbar = $SubViewport/HealthBar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("ghost")
	player = get_node(player_path)
	state = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	match state.get_current_node():
		"walk":
			new_agent.set_target_position(player.global_transform.origin)
			var nvp = new_agent.get_next_path_position()
			velocity = (nvp - global_transform.origin).normalized() * speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"sprint":
			new_agent.set_target_position(player.global_transform.origin)
			var nvp = new_agent.get_next_path_position()
			velocity = (nvp - global_transform.origin).normalized() * (speed + 1.5)
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"attack-kick-left":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"attack-melee-right":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/sprint", _target_in_Srange())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	move_and_slide()

func _target_in_range(extra_range:= 0.0):
	var offset = player.global_position - global_position
	var horizontal_distance = Vector2(offset.x, offset.z).length()
	var vertical_distance = abs(offset.y)
	return horizontal_distance < attack_range + extra_range and vertical_distance < 4.0
	
	#return global_position.distance_to(player.global_position) < attack_range
func _target_in_Srange():
	return global_position.distance_to(player.global_position) < sprint_range


func _hit_finished():
	if _target_in_range(1.0):
		var dir = global_position.direction_to(player.global_position)
		dir.y = clamp(dir.y, 0.0, 0.4)
		player.hit(dir)


func _on_area_3d_ghost_hit(dam: Variant) -> void:
	health -= dam * player.FireDamage
	healthbar.health = health
	if health <= 0:
		set_physics_process(false)
		set_process(false)
		collision_layer = 4
		collision_mask = 4
		for node in find_children("*"):
			if node is Area3D:
				node.monitoring = false
				node.monitorable = false
		for node in find_children("*"):
			if node is CollisionShape3D:
				node.disabled = true
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(2.2).timeout
		queue_free()
