extends Node3D
@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Spawns
@onready var ghost_spawns = $G_Spawns
@onready var nav_region = $NavigationRegion3D
var zombie = load("res://Scenes/zombie.tscn")
var ghost = load("res://Scenes/ghost.tscn")
var instance_zombie
var instance_ghost
@onready var death_screen = $UI/DeathScreen
@onready var player = $NavigationRegion3D/Player
var enemies_inside = []
var zombie_count = 0
var ghost_count = 0
var timer_state = false
signal thriller
@onready var timer = $Area3D/Timer
@onready var txt = $TextEdit
@onready var txt2 = $TextEdit2
var player_inside = false
@onready var nav_link = $NavigationRegion3D/NavigationLink3D
@onready var asp = $AudioStreamPlayer3D
@onready var asp2 = $AudioStreamPlayer3D2
@onready var asp3 = $AudioStreamPlayer3D3
@onready var asp4 = $AudioStreamPlayer3D4
var fullscrene = false
@onready var spawn_timer = $Spawn_timer
@onready var G_spawn_timer = $G_Spawn_timer
@onready var wave2 = $UI/Label3
@onready var win_screen = $UI/WinScreen
var open_sound = load("res://sounds/dragon-studio-open-door-stock-sfx-454246.mp3")
var close_sound = load("res://sounds/dragon-studio-open-and-close-door-405453.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	win_screen.visible = false
	asp.stream = open_sound
	asp2.stream = open_sound
	asp3.stream = open_sound
	asp4.stream = open_sound
	
	nav_link.enabled = false
	randomize()
	await get_tree().create_timer(3.0).timeout
	asp.play()
	asp2.play()
	asp3.play()
	asp4.play()
	$"NavigationRegion3D/crypt-small/crypt-door2/AnimationPlayer".play("open")
	$"NavigationRegion3D/crypt-large/crypt-large-door2/AnimationPlayer".play("open")
	$"NavigationRegion3D/crypt-small2/crypt-door2/AnimationPlayer".play("open")
	$"NavigationRegion3D/crypt-small3/crypt-door2/AnimationPlayer".play("open")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Fullscrene") and !fullscrene:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscrene = true
	elif Input.is_action_just_pressed("Fullscrene") and fullscrene:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscrene = false
	
	
	
	enemies_inside = enemies_inside.filter(is_instance_valid)
	if enemies_inside.size() > 0 and timer_state == false and player_inside == true:
		#print("get lost")
		timer_state = true
		timer.start()
		$Area3D/Timer2.start()
		txt.visible = true
	elif player_inside == false:
		#print("nice")
		timer_state = false
		
		txt.visible = false
		txt2.visible = false
		timer.stop()
		nav_link.enabled = false
		for zombie in get_tree().get_nodes_in_group("zombie"):
			zombie.new_agent.path_desired_distance = 1.0
		for ghost in get_tree().get_nodes_in_group("ghost"):
			ghost.new_agent.path_desired_distance = 1.0


func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func _on_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("zombie").size() >= 10:
		return
	var spawn_point = _get_random_child(spawns).global_position
	instance_zombie = zombie.instantiate()
	instance_zombie.position = spawn_point + Vector3(
	randf_range(-0.1, 0.1),
	0,
	randf_range(-0.1, 0.1))
	
	#instance_zombie.position = spawn_point
	nav_region.add_child(instance_zombie)

func _on_player_player_died() -> void:
	death_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_g_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("ghost").size() >= 10:
		return
	var spawn_point2 = _get_random_child(ghost_spawns).global_position
	instance_ghost = ghost.instantiate()
	instance_ghost.position = spawn_point2 + Vector3(
	randf_range(-0.1, 0.1),
	0,
	randf_range(-0.1, 0.1))
	nav_region.add_child(instance_ghost)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("zombie") or body.is_in_group("ghost"):
		enemies_inside.append(body)
	if body == player:
		player_inside = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body in enemies_inside:
		enemies_inside.erase(body)
	if body == player:
		player_inside = false


func _on_timer_timeout() -> void:
	#print("5awal, etla3 barrah")
	txt.visible = false
	txt2.visible = true
	nav_link.enabled = true
	for zombie in get_tree().get_nodes_in_group("zombie"):
		zombie.new_agent.path_desired_distance = 2.0
	for ghost in get_tree().get_nodes_in_group("ghost"):
			ghost.new_agent.path_desired_distance = 2.0


func _on_timer_2_timeout() -> void:
	txt.visible = false
	txt2.visible = false
	$TextEdit3.visible = true
	player.global_transform = $NavigationRegion3D/Node3D/Node3D.global_transform
	
	$NavigationRegion3D/zombie.global_transform = $NavigationRegion3D/Node3D/Node3D3.global_transform
	$NavigationRegion3D/zombie2.global_transform = $NavigationRegion3D/Node3D/Node3D2.global_transform
	$NavigationRegion3D/zombie3.global_transform = $NavigationRegion3D/Node3D/Node3D4.global_transform
	emit_signal("thriller")


func _on__timeout() -> void:
	wave2.visible = true
	spawn_timer.wait_time = 1.0
	G_spawn_timer.wait_time = 1.0
	await get_tree().create_timer(5.0).timeout
	wave2.visible = false


func _on_end_timeout() -> void:
		asp.stream = close_sound
		asp2.stream = close_sound
		asp3.stream = close_sound
		asp4.stream = close_sound
		asp.play()
		asp2.play()
		asp3.play()
		asp4.play()
		$"NavigationRegion3D/crypt-small/crypt-door2/AnimationPlayer".play("close")
		$"NavigationRegion3D/crypt-large/crypt-large-door2/AnimationPlayer".play("close")
		$"NavigationRegion3D/crypt-small2/crypt-door2/AnimationPlayer".play("close")
		$"NavigationRegion3D/crypt-small3/crypt-door2/AnimationPlayer".play("close")
		await get_tree().create_timer(2.0).timeout
		win_screen.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true


func _on_main_menu_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
