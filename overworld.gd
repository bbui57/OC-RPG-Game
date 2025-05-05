extends Node3D

@onready var camera = $CameraPivot/Camera3D
@onready var fps_label = $ScreenUI/FPSLabel
@onready var pause_menu = $Panel/EscMenu
@onready var camera_pivot = $CameraPivot

# Character variables
var player_scene = load(Global.characters[Global.selected_character]) # Load the player scene
var character

# Camera Movement variables
var sensitivity = 0.2
var rotation_y = 0
var rotation_x = 0
var is_dragging = false

func _ready():
	# Instantiate the character
	character = player_scene.instantiate()
	character.position = Vector3(0, 2, 0)
	add_child(character)
	print("Player instantiated successfully!")
	
	#Initialize Player and Camera Positioning
	camera_pivot.position = Vector3(0, 2, 5)
	character.position = Vector3(0, 2, 0)
	camera.look_at(character.position)
	
	#Show mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var target_position = character.position + Vector3(0, 2, 5)
	camera_pivot.position = camera_pivot.position.lerp(target_position, 0.1)
	camera.look_at(character.position)
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	
func _input(event):
	if event.is_action_pressed("ui_cancel"): # Escape key
		toggle_pause()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.size += 0.5
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.size -= 0.5
	if is_dragging and event is InputEventMouseMotion:
		rotate_camera(event.relative)
			
func rotate_camera(mouse_movement):
	rotation_y -= mouse_movement.x * sensitivity
	rotation_x -= mouse_movement.y * sensitivity
	camera_pivot.rotation.y = deg_to_rad(rotation_y)
	camera_pivot.rotation.x = deg_to_rad(rotation_x)

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
	
