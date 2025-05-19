extends CharacterBody2D  # Ensure it’s a character with movement capability

@export var stop_distance: float = 1.0  # Prevent overcrowding

@onready var anim = $AnimatedSprite2D

var player  # Reference to the selected character
var speed = 200
var facing = "front"
var update_timer = 0.0
var update_interval = 0.5
var follower_index
var prev_position = global_position

func _ready():
	player = get_tree().get_first_node_in_group("player")  # Find the player automatically
	set_collision_layer_value(3, 1)
	set_collision_mask_value(1, 1)
	set_collision_layer_value(2, 0)

func _physics_process(_delta):
	
	velocity = Vector2.ZERO
	
	if Engine.time_scale == 0:
		return
	
	if player.velocity.length() > 0:
		update_position()
	
	handle_animation(velocity)
	
	move_and_slide()

func _input(event):
	if event.is_action_pressed("interact") and $Prompt.visible:
		get_tree().get_root().find_child("HUD", true, false).visible = false
		open_dialogue()

func update_position():
	var path_index = 100 - ((follower_index) * 20)
	if path_index < player.path_queue.size():
		global_position = global_position.lerp(player.path_queue[path_index], 0.1)
		
	velocity = global_position - prev_position
	prev_position = global_position

func handle_animation(vel):
	if vel.length() > 0.1:
		if abs(vel.x) > abs(vel.y):
			facing = "right" if vel.x > 0 else "left"
		else:
			facing = "front" if vel.y > 0 else "back"
	
		anim.play("move_" + facing)
	else:
		anim.play("stand_" + facing)

func update_index():
	if not get_tree(): return
	print(get_tree().get_nodes_in_group("follower"))
	var i = 1
	for follower in get_tree().get_nodes_in_group("follower"):
		follower.follower_index = i
		i += 1
		print(follower.name, ": ", follower.follower_index)

func open_dialogue():
	var dialogue_ui = get_tree().get_root().find_child("Dialogue", true, false)
	dialogue_ui.visible = true
