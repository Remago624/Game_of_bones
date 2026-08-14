extends Control
@onready var StreamPlayer = $AudioStreamPlayer2D
@onready var main_buttons = $VBoxContainer
@onready var options = $options
var click = load("res://sounds/click.mp3")
var tick1 = load("res://sounds/tick1.mp3")
var tick2 = load("res://sounds/tick2.mp3")
var tick3 = load("res://sounds/tick3.mp3")
var tick4 = load("res://sounds/tick4.mp3")
var ticks = [tick1, tick2, tick3, tick4]
@onready var bgm1 = load("res://sounds/shadowsandechoes-deep-core-loop-version-325061.mp3")
@onready var bgm2 = load("res://sounds/shadowsandechoes-dark-legacy-loop-version-325059.mp3")
@onready var bgmplayer = $BGMusic

@onready var fps = $Label2
#@onready var fps = $Label2
var mute = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	bgmplayer.stream = bgm1
	bgmplayer.play()
	main_buttons.visible = true
	options.visible = false
	fps.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fps.text = str(Engine.get_frames_per_second()) + " FPS"


func _on_start_pressed() -> void:
	_click()
	await get_tree().create_timer(0.067).timeout
	get_tree().change_scene_to_file("res://Scenes/node_3d.tscn")


func _on_settings_pressed() -> void:
	_click()
	main_buttons.visible = false
	options.visible = true


func _on_exti_pressed() -> void:
	_click()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _on_button_mouse_entered() -> void:
	_random_tick()


func _on_button_2_mouse_entered() -> void:
	_random_tick()


func _on_button_3_mouse_entered() -> void:
	_random_tick()

func _random_tick() -> void:
	StreamPlayer.stream = ticks.pick_random()
	StreamPlayer.play()
func _click():
	StreamPlayer.stream = click
	StreamPlayer.play()


func _on_x_pressed() -> void:
	_click()
	main_buttons.visible = true
	options.visible = false


func _on_item_list_item_selected(index: int) -> void:
	if index == 0:
		_click()
		bgmplayer.stream = bgm1
		bgmplayer.play()
	elif index == 1:
		_click()
		bgmplayer.stream = bgm2
		bgmplayer.play()


func _on_h_slider_value_changed(value: float) -> void:
	if value <= 0:
		bgmplayer.volume_db = -80
	else:
		bgmplayer.volume_db = linear_to_db(value / 100.0)


func _on_mute_pressed() -> void:
	_click()
	if !mute:
		mute = true
		$options/Label2/HSlider.value = 0
		$options/Label2/Button.icon = load("res://sounds/Untitled.png")
	elif mute:
		mute = false
		$options/Label2/HSlider.value = 50
		$options/Label2/Button.icon = load("res://sounds/Untitled1.png")


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_v_sync_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	elif !toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_show_fps_toggled(toggled_on: bool) -> void:
	fps.visible = toggled_on
