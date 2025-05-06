extends Node3D

@onready var camera = $CameraPivot/Camera3D
@onready var fps_label = $ScreenUI/FPSLabel
@onready var pause_menu = $Panel/EscMenu
@onready var camera_pivot = $CameraPivot

# Character variables
var player_scene = load(Global.characters[Global.selected_character]) # Load the player scene
var character
var npc1
var npc2
var npc3

# Camera Movement variables
var sensitivity = 0.2
var rotation_y = 0
var rotation_x = 0
var is_dragging = false


func _ready():
	# Instantiate the characters
	spawn_characters()
	character = get_tree().get_first_node_in_group("player")
	
	#Initialize Player and Camera Positioning
	camera_pivot.position = Vector3(0, 2, 5)
	character.position = Vector3(0, 2, 0)
	camera.look_at(character.position)
	
	#Show mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$ScreenUI/VBoxContainer/Character1/Button.connect("pressed", swap_character.bind(0))
	$ScreenUI/VBoxContainer/Character2/Button.connect("pressed", swap_character.bind(1))
	$ScreenUI/VBoxContainer/Character3/Button.connect("pressed", swap_character.bind(2))
	$ScreenUI/VBoxContainer/Character4/Button.connect("pressed", swap_character.bind(3))

func _physics_process(delta):
	var target_position = character.position + Vector3(0, 2, 5)
	camera_pivot.position = camera_pivot.position.lerp(target_position, 5.0 * delta)
	
	var camera_forward = camera_pivot.global_transform.basis.z
	var target_rotation = atan2(camera_forward.x, camera_forward.z)
	character.rotation.y = lerp_angle(character.rotation.y, target_rotation, 0.1)
	
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
	if event.is_action_pressed("swap_char_1"):
		swap_character(0)
	if event.is_action_pressed("swap_char_2"):
		swap_character(1)
	if event.is_action_pressed("swap_char_3"):
		swap_character(2)
	if event.is_action_pressed("swap_char_4"):
		swap_character(3)
			
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

func spawn_characters():
	var player_instance = load(Global.characters[Global.selected_character]).instantiate()
	player_instance.set_script(preload("res://scripts/character.gd"))
	print(player_instance.name)
	set_player(player_instance)
	player_instance.scale = Vector3(4, 4, 4)
	add_child(player_instance)  # ✅ Add player first!
	
	var prev_panel = get_node("ScreenUI/VBoxContainer/Character" + str(Global.selected_character + 1) + "/Panel")
	prev_panel.visible = true

	for i in range(len(Global.characters)):
		if i == Global.selected_character:
			continue  # Skip already added player
		
		var follower = load(Global.characters[i]).instantiate()
		follower.set_script(preload("res://scripts/follower.gd"))
		follower.position = Vector3(randf_range(-2, 2), 1, randf_range(-2, 2))
		follower.scale = Vector3(4, 4, 4)
		
		follower.add_to_group("follower")
		add_child(follower)

func set_player(player):
	player.add_to_group("player")
	player.remove_from_group("follower")
	for follower in get_tree().get_nodes_in_group("player"):
		if follower != player:
			follower.remove_from_group("player")
			follower.add_to_group("follower")
	character = get_tree().get_first_node_in_group("player")
		
func swap_character(new_index):
	
	var prev_char_instance = get_node(Global.char_names[Global.selected_character])
	prev_char_instance.set_script(preload("res://scripts/follower.gd"))
	var prev_panel = get_node("ScreenUI/VBoxContainer/Character" + str(Global.selected_character + 1) + "/Panel")
	prev_panel.visible = false  
	
	var new_char_instance = get_node(Global.char_names[new_index])
	new_char_instance.set_script(preload("res://scripts/character.gd"))
	var new_panel = get_node("ScreenUI/VBoxContainer/Character" + str(new_index + 1) + "/Panel")
	new_panel.visible = true
	
	set_player(new_char_instance)
	Global.selected_character = new_index
	
	for follower in get_tree().get_nodes_in_group("follower"):
		follower.player = new_char_instance

func _on_resume_button_pressed():
	Engine.time_scale = 1
	pause_menu.visible = false
	$Panel.visible = false
	
func _on_quit_button_pressed():
	get_tree().quit()
	
