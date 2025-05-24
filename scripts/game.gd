extends Node2D

var camera_zoom = Vector2(6, 6)

@onready var fps_label = UI.get_node("HUD/FPSLabel")
@onready var pause_menu = UI.get_node("EscMenu")
@onready var camera = $Camera2D

# Character variables
var player_scene = load(Global.characters[Global.selected_character]) # Load the player scene
var player
var follower_index = 0

# Map Generation variables
const dir = [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]
var grid_size = 100
var grid_steps = 1000

func _ready():
	spawn_characters()
	
	camera.set_zoom(camera_zoom)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	UI.get_node("HUD/Party/Character1/Button").connect("pressed", swap_character.bind(0))
	UI.get_node("HUD/Party/Character2/Button").connect("pressed", swap_character.bind(1))
	UI.get_node("HUD/Party/Character3/Button").connect("pressed", swap_character.bind(2))
	UI.get_node("HUD/Party/Character4/Button").connect("pressed", swap_character.bind(3))

func _process(_delta):
	
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	
	camera.global_position = camera.global_position.lerp(player.global_position, 0.1)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Escape key
		toggle_pause()
	if event.is_action_pressed("swap_char_1"):
		swap_character(0)
	if event.is_action_pressed("swap_char_2"):
		swap_character(1)
	if event.is_action_pressed("swap_char_3"):
		swap_character(2)
	if event.is_action_pressed("swap_char_4"):
		swap_character(3)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_zoom -= Vector2(0.1, 0.1)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_zoom += Vector2(0.1, 0.1)
		camera_zoom = clamp(camera_zoom, Vector2(4, 4), Vector2(10, 10))
		camera.set_zoom(camera_zoom)

func toggle_pause():
	if Engine.time_scale == 1:
		Engine.time_scale = 0
		pause_menu.visible = true
	else:
		_on_resume_button_pressed()

func spawn_characters():
	var player_instance = load(Global.characters[Global.selected_character]).instantiate()
	player_instance.set_script(preload("res://scripts/player.gd"))
	player_instance.position = Vector2(180, 190)

	add_child(player_instance)
	set_player(player_instance)
	
	var prev_panel = UI.get_node("HUD/Party/Character" + str(Global.selected_character + 1) + "/Panel")
	prev_panel.visible = true
	
	var pos = player_instance.position
	for i in range(len(Global.characters)):
		if i == Global.selected_character:
			continue  # Skip already added player
		
		var follower = load(Global.characters[i]).instantiate()
		follower.set_script(preload("res://scripts/follower.gd"))
		
		pos -= Vector2(0, 64)
		follower.position = pos

		add_child(follower)
		follower.add_to_group("follower")
		follower.update_index()

func set_player(character):
	character.add_to_group("player")
	character.remove_from_group("follower")
	for follower in get_tree().get_nodes_in_group("player"):
		if follower != character:
			follower.remove_from_group("player")
			follower.add_to_group("follower")
			
	player = character

func swap_character(new_index):
	
	var prev_char_instance = get_node(Global.char_names[Global.selected_character])
	var new_char_instance = get_node(Global.char_names[new_index])
	
	if prev_char_instance == new_char_instance: return
	
	prev_char_instance.set_script(preload("res://scripts/follower.gd"))
	new_char_instance.set_script(preload("res://scripts/player.gd"))
	
	prev_char_instance._ready()
	new_char_instance._ready()
	
	var prev_panel = UI.get_node("HUD/Party/Character" + str(Global.selected_character + 1) + "/Panel")
	prev_panel.visible = false  
	var new_panel = UI.get_node("HUD/Party/Character" + str(new_index + 1) + "/Panel")
	new_panel.visible = true
	
	set_player(new_char_instance)
	Global.selected_character = new_index
	
	for follower in get_tree().get_nodes_in_group("follower"):
		follower.player = new_char_instance
		follower.update_index()

func _on_resume_button_pressed():
	Engine.time_scale = 1
	pause_menu.visible = false
	$EscMenu.visible = false
	
func _on_quit_button_pressed():
	get_tree().quit()
	
