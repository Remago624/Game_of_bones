extends CharacterBody3D
var mouse_sens: float = 0.001
var speed = 5.0
const walk_speed = 5.0
const sprint_speed = 8.0
const maya3a_speed = 3.0
var JUMP_VELOCITY = 4.5
const crouchJ_change = 1.0
const crouchV_change = 0.3
@onready var P = $"."
@onready var rot := $Node3D
@onready var camera = $Node3D/Camera3D
@onready var TopDownCamera = $TopDownCamera
const FOV = 70.0
const FOV_change = 1.5
const bob_freq = 2.0
const bob_amp = 0.08
var t_bob = 0.0
var FireDamage = 1.0
#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
var bullet = load("res://Scenes/bullet.tscn")
var instance
var instance2
@onready var gun_anim = $"Node3D/Camera3D/Root Scene/AnimationPlayer"
@onready var gun_anim2 = $"Node3D/Camera3D/Root Scene2/AnimationPlayer"
@onready var gun_ray_cast = $"Node3D/Camera3D/Root Scene/RayCast3D"
@onready var gun_ray_cast2 = $"Node3D/Camera3D/Root Scene2/RayCast3D"
@onready var gun = $"Node3D/Camera3D/Root Scene"
@onready var node3d = $Node3D
var health = 100.0
var zombie_damage
signal player_hit
const hit_stagger = 8.0

const aim_assist_start = 3.0
const aim_assist_end = 7.0
var lo = -0.10
var ro = 0.10
var s = 0.067
var left_offset = -0.10
var right_offset = 0.10
var spread = 0.067

signal player_died

@onready var healthbar = $"../../HealthBar"
var cameraV = false
var mouse_position := Vector3.ZERO
const ray_length = 1000
@onready var mr = rot

func _ready():
	randomize()
	healthbar.init_health(health)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera") and !cameraV:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		camera.clear_current()
		TopDownCamera.make_current()
		cameraV = true
		mr = P
		camera.rotation.x = 0
	elif event.is_action_pressed("camera") and cameraV:
		cameraV = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		TopDownCamera.clear_current()
		camera.make_current()
	
	
	if event is InputEventMouseButton and !cameraV:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rot.rotate_y(-event.relative.x * mouse_sens)
			camera.rotate_x(-event.relative.y * mouse_sens)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _physics_process(delta: float) -> void:
	var directionP = mouse_position - rot.global_position
	directionP.y = 0
	var angle = atan2(-directionP.x, -directionP.z)
	if cameraV:
		_mouse_position()
		rot.rotation.y = angle
	else:
		mr = rot
	
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (mr.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#walk and sprint
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	elif Input.is_action_pressed("maya3a"):
		speed = maya3a_speed
	else:
		speed = walk_speed
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)	
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		
	if Input.is_action_just_pressed("shoot"):
		_on_fire_timer_timeout()
		$FireTimer.start()
	if Input.is_action_just_released("shoot"):
		$FireTimer.stop()
		gun_anim.play("RESET")
		gun_anim2.play("RESET")
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 5.0, sprint_speed * 2)
	var target_FOV = FOV + FOV_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_FOV, delta * 6.0)
	
	_crouch()
	if !Input.is_action_pressed("maya3a"):
		spread = s + velocity.length() * 0.02
		
	else:
		spread = s
		
	if Input.is_key_label_pressed(KEY_G):
		health += 1
		healthbar.health = health
	
	
	move_and_slide()


func _on_fire_timer_timeout() -> void:
	var from = camera.global_position
	var to = from + -camera.global_transform.basis.z * 1000.0

	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var result = space.intersect_ray(query)
	var target = to
	
	if !result.is_empty():
		target = result.position
	else:
		target = from + -camera.global_transform.basis.z * 35.0
	
	var camera_basis = camera.global_basis
	var random_right = randf_range(-spread, spread)
	var random_up = randf_range(-spread, spread)
	var right = camera.global_transform.basis.x
	var up = camera.global_transform.basis.y
	var target1 = target + right * (right_offset + random_right) + up * random_up
	var target2 = target + right * (left_offset + random_up) + up * random_right
	
	var target_basis1 = Basis.looking_at((target1 - gun_ray_cast.global_position).normalized())
	var target_basis2 = Basis.looking_at((target2 - gun_ray_cast2.global_position).normalized())
		#var target_basis1 = Basis.looking_at((target - gun_ray_cast.global_position).normalized())
		#var target_basis2 = Basis.looking_at((target - gun_ray_cast2.global_position).normalized())
	if !result.is_empty():
		var distance = from.distance_to(target)
		var weight = clamp((distance - aim_assist_start) / (aim_assist_end - aim_assist_start), 0.0, 1.0)
		gun_ray_cast.global_basis = camera_basis.slerp(target_basis1, weight)
		gun_ray_cast2.global_basis = camera_basis.slerp(target_basis2, weight)
	else:
		gun_ray_cast.global_basis = target_basis1
		gun_ray_cast2.global_basis = target_basis2
	
	
	
	gun_anim.play("shoot")
	gun_anim2.play("shoot")
	instance = bullet.instantiate()
	instance2 = bullet.instantiate()
	instance.position = gun_ray_cast.global_position
	instance2.position = gun_ray_cast2.global_position
	
	
	
	instance.transform.basis = gun_ray_cast.global_transform.basis
	instance2.transform.basis = gun_ray_cast2.global_transform.basis
	get_parent().add_child(instance)
	get_parent().add_child(instance2)


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos

func hit(dir):
	emit_signal("player_hit")
	zombie_damage = randi_range(15, 35)
	health -= zombie_damage
	healthbar.health = health
	if health <= 0:
		emit_signal("player_died")
		return
	velocity += dir * hit_stagger
func _crouch():
	if Input.is_action_just_pressed("maya3a"):
		node3d.global_position.y -= crouchV_change
		JUMP_VELOCITY -= crouchJ_change
	elif Input.is_action_just_released("maya3a"):
		node3d.global_position.y += crouchV_change
		JUMP_VELOCITY += crouchJ_change
		
func _mouse_position():
	var mouse_screen_position = get_viewport().get_mouse_position()
	var space_state = get_world_3d().direct_space_state
	var from = TopDownCamera.project_ray_origin(mouse_screen_position)
	var to = from + TopDownCamera.project_ray_normal(mouse_screen_position) * ray_length
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result:
		mouse_position = result.position
		print(result.position)
