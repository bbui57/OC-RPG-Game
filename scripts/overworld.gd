extends Node3D

@onready var camera = $CameraPivot/Camera3D
@onready var fps_label = $HUD/FPSLabel
@onready var pause_menu = $EscMenu
@onready var camera_pivot = $CameraPivot
@onready var gridmap = $NavigationRegion3D/GridMap

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

# Map Generation variables
const dir = [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]
var grid_size = 15
var grid_steps = 50

func _ready():
	generate_map()
	spawn_characters()
	character = get_tree().get_first_node_in_group("player")
	
	#Initialize Player and Camera Positioning
	camera_pivot.position = Vector3(0, 2, 5)
	character.position = Vector3(0, 1.5, 0)
	camera.look_at(character.position)
	
	#Show mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$HUD/VBoxContainer/Character1/Button.connect("pressed", swap_character.bind(0))
	$HUD/VBoxContainer/Character2/Button.connect("pressed", swap_character.bind(1))
	$HUD/VBoxContainer/Character3/Button.connect("pressed", swap_character.bind(2))
	$HUD/VBoxContainer/Character4/Button.connect("pressed", swap_character.bind(3))

func _physics_process(delta):
	var target_position = character.position + Vector3(0, 2, 5)
	camera_pivot.position = camera_pivot.position.lerp(target_position, 5.0 * delta)
	
	var camera_forward = camera_pivot.global_transform.basis.z
	var target_rotation = atan2(camera_forward.x, camera_forward.z)
	character.rotation.y = lerp_angle(character.rotation.y, target_rotation, 0.1)
	
	for follower in get_tree().get_nodes_in_group("follower"):
		follower.rotation.y = lerp_angle(follower.rotation.y, target_rotation, 0.1)
	
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
	else:
		_on_resume_button_pressed()

func generate_map():
	# Create map (procedural generation)
	gridmap.set_cell_item(Vector3.ZERO, 3, 0) #Origin
	gridmap.set_cell_item(Vector3(-1,0,-1),3,0)
	randomize()
	var curr_pos = Vector3.ZERO
	var curr_dir = Vector3.RIGHT
	var last_dir = curr_dir * -1
	
	#Pick next tile location
	for i in range(0, grid_steps):
		var temp_dir = dir.duplicate()
		temp_dir.shuffle()
		var d = temp_dir.pop_front()
		
		while (abs(curr_pos.x + d.x) > grid_size or abs(curr_pos.z + d.z) > grid_size or d == last_dir * -1):
			temp_dir.shuffle()
			d = temp_dir.pop_front()
			
		curr_pos += d
		last_dir = d
		
		#Place tile
		gridmap.set_cell_item(curr_pos, 3, 0)
	$NavigationRegion3D.bake_navigation_mesh()

func spawn_characters():
	var player_instance = load(Global.characters[Global.selected_character]).instantiate()
	player_instance.set_script(preload("res://scripts/character.gd"))
	print(player_instance.name)
	set_player(player_instance)
	player_instance.scale = Vector3(4, 4, 4)
	add_child(player_instance)  # ✅ Add player first!
	
	var prev_panel = get_node("HUD/VBoxContainer/Character" + str(Global.selected_character + 1) + "/Panel")
	prev_panel.visible = true

	for i in range(len(Global.characters)):
		if i == Global.selected_character:
			continue  # Skip already added player
		
		var follower = load(Global.characters[i]).instantiate()
		follower.set_script(preload("res://scripts/follower.gd"))
		follower.position = valid_spawn_position()
			
		follower.scale = Vector3(4, 4, 4)
		
		follower.add_to_group("follower")
		add_child(follower)

func valid_spawn_position():
	gridmap = $NavigationRegion3D/GridMap
	var spawn_position = Vector3(randf_range(-2, 2), 1.5, randf_range(-2, 2))
	for attempt in range(100):
		var random_x = randf_range(-2, 2)
		var random_z = randf_range(-2, 2)
		spawn_position = Vector3(random_x, 1.5, random_x)
		
		var grid_position = gridmap.local_to_map(spawn_position)
		var cell_item = gridmap.get_cell_item(grid_position)
		
		if cell_item != -1:
			break
	return spawn_position

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
	var prev_panel = get_node("HUD/VBoxContainer/Character" + str(Global.selected_character + 1) + "/Panel")
	prev_panel.visible = false  
	
	var new_char_instance = get_node(Global.char_names[new_index])
	new_char_instance.set_script(preload("res://scripts/character.gd"))
	var new_panel = get_node("HUD/VBoxContainer/Character" + str(new_index + 1) + "/Panel")
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
	
