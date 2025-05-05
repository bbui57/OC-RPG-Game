extends Node3D

@onready var camera = $Camera3D
@onready var fps_label = $ScreenUI/FPSLabel
@onready var pause_menu = $Panel/EscMenu

var player_scene = preload("res://player.tscn") # Load the player scene

func _ready():
	if get_node_or_null("Player") == null:  # Check if Player exists
		var player_instance = player_scene.instantiate()
		player_instance.position = Vector3(0, 2, 0)
		add_child(player_instance)
		print("Player instantiated successfully!")
	else:
		print("Player already exists, skipping instantiation.")
	
	camera.position = Vector3(0, 3, 7)
	$Player.position = Vector3(0, 2, 0)
	camera.look_at($Player.position)
	

func _process(delta):
	camera.position = lerp(camera.position, $Player.position + Vector3(0, 3, 7), 1)
	camera.look_at($Player.position)
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	if Engine.time_scale == 1:
		Engine.time_scale = 0
		pause_menu.visible = true
		$Panel.visible = true
	else:
		_on_resume_button_pressed()
		
func _on_resume_button_pressed():
	Engine.time_scale = 1
	pause_menu.visible = false
	$Panel.visible = false
	
func _on_quit_button_pressed():
	get_tree().quit()
