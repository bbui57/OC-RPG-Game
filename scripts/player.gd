extends CharacterBody2D

@export var speed: float = 200.0

@onready var anim = $AnimatedSprite2D

var facing = "front"
var nearby_characters = []

var path_queue = []
var max_steps = 32

func _ready():
	anim = get_node("AnimatedSprite2D")
	nearby_characters = []
	$Area2D.connect("body_entered", Callable(self, "_on_Area2D_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_Area2D_body_exited"))
	set_collision_layer(2)
	set_collision_mask(1)
	collision_layer &= ~3

func _physics_process(delta):
	
	z_index = max(position.y * 1.5, 1)
	velocity = Vector2.ZERO
	
	if anim == null:
		anim = get_node_or_null("AnimatedSprite2D")

	if Engine.time_scale == 0:
		return
	
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
		facing = "right"
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
		facing = "left"
	if Input.is_action_pressed("move_down"):
		velocity.y = 1
		facing = "front"
	if Input.is_action_pressed("move_up"):
		velocity.y = -1
		facing = "back"
	
	# Handle multiple movement inputs
	var input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if abs(input.x) > abs(input.y):
		input.y = 0
	else:
		input.x = 0
		
	velocity = input.normalized() * speed

	if velocity.length() > 0:
		path_queue.append(global_position)
		anim.play("move_" + facing)
	else:
		if anim.is_playing():
			anim.play("stand_" + facing)

	if path_queue.size() > max_steps:
		path_queue.pop_front()

	move_and_slide()
	
	var closest = get_closest_character()
	if nearby_characters.is_empty():
		for character in get_tree().get_nodes_in_group("follower"):
			character.get_node("Prompt").visible = false
	else:
		for character in nearby_characters:
			character.get_node("Prompt").visible = (character == closest) and closest != null

func _on_Area2D_body_entered(body):
	if body.is_in_group("follower"):
		nearby_characters.append(body)

func _on_Area2D_body_exited(body):
	if body in nearby_characters:
		nearby_characters.erase(body)

func get_closest_character():
	var player_position = global_transform.origin
	var closest_character = null
	var closest_distance = INF
	
	for character in nearby_characters:
		var distance = player_position.distance_to(character.global_transform.origin)
		if distance < closest_distance:
			closest_distance = distance
			closest_character = character
			
	return closest_character
