extends CharacterBody3D

const speed = 4.0
var player = null
var state
@export var player_path := "/root/world/NavigationRegion3D/Player"
@onready var new_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var anim_player2 = $AnimationPlayer2
@onready var Skeleton = $Armature/Skeleton3D
@onready var armature = $Armature
const attack_range = 2.0
var health = 200

@onready var healthbar = $SubViewport/HealthBar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player = get_tree().get_first_node_in_group("player") this for old issue, and don't worry I solved it
	add_to_group("zombie")
	player = get_node(player_path)
	state = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	match state.get_current_node():
		"running":
			new_agent.set_target_position(player.global_transform.origin)
			var nvp = new_agent.get_next_path_position()
			velocity = (nvp - global_transform.origin).normalized() * speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"attack2":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		

	
	#look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())

	move_and_slide()

func _target_in_range(extra_range:= 0.0):
	var offset = player.global_position - global_position
	
	var horizontal_distance = Vector2(offset.x, offset.z).length()
	var vertical_distance = abs(offset.y)
	
	return horizontal_distance < attack_range + extra_range and vertical_distance < 4.0
	
	#return global_position.distance_to(player.global_position) < attack_range

func _hit_finished():
	if _target_in_range(1.0):
		var dir = global_position.direction_to(player.global_position)
		dir.y = clamp(dir.y, 0.0, 0.4)
		player.hit(dir)


func _on_area_3d_body_part_hit(dam: Variant) -> void:
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
		


func _on_world_thriller() -> void:
	#print("THRILLER SIGNAL RECEIVED")
	#print("Has animation: ", anim_player2.has_animation("thriller"))

	#anim_player2.play("thriller")

	#print("Playing: ", anim_player2.is_playing())
	#print("Current: ", anim_player2.current_animation)
	#print("Length: ", anim_player2.current_animation_length)

	#await get_tree().create_timer(2.0).timeout

	#print("After 2 sec - Playing: ", anim_player2.is_playing())
	#print("Position: ", anim_player2.current_animation_position)
	health = 99999999
	set_physics_process(false)
	anim_tree.active = false
	anim_player2.play("thriller")
	await get_tree().create_timer(18.8667).timeout
	anim_player2.play("thriller", -1.0, -4.0, true)
	await get_tree().create_timer(4.716675).timeout
	anim_tree.set("parameters/conditions/thriller", true)
	anim_tree.active = true
	set_physics_process(true)
