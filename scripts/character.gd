extends CharacterBody3D

@export var speed: float = 50.0
@export var gravity: float = 50.0
@export var jump: float = 20.0

@onready var anim = $AnimatedSprite3D

var facing = "front"
var nearby_characters = []

func _ready():
	anim = get_node("AnimatedSprite3D")
	nearby_characters = []
	$Area3D.connect("body_entered", Callable(self, "_on_Area3D_body_entered"))
	$Area3D.connect("body_exited", Callable(self, "_on_Area3D_body_exited"))
	set_process(true)

func _physics_process(delta):
	
	velocity = Vector3.ZERO	
	
	if anim == null:
		anim = get_node_or_null("AnimatedSprite3D")
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Engine.time_scale == 0:
		return

	
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
		facing = "right"
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
		facing = "left"
	if Input.is_action_pressed("move_down"):
		velocity.z = 1
		facing = "front"
	if Input.is_action_pressed("move_up"):
		velocity.z = -1
		facing = "back"
	
	# Handle multiple movement inputs
	var input = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if abs(input.x) > abs(input.z):
		input.z = 0
	else:
		input.x = 0

	if velocity.length() > 0:
		var move_direction = transform.basis * input
		velocity.x = move_direction.x * speed * delta
		velocity.z = move_direction.z * speed * delta

		anim.play("move_" + facing)
	else:
		if anim.is_playing():
			anim.play("stand_" + facing)
	
	if position.y < -1:
		position.y = 3
	move_and_slide()
	
	var closest = get_closest_character()
	for character in nearby_characters:
		var prompt = character.get_node("AnimatedSprite3D/UI")
		if character == closest:
			prompt.visible = true
		else:
			prompt.visible = false

func _on_Area3D_body_entered(body):
	if body.is_in_group("follower"):
		nearby_characters.append(body)

func _on_Area3D_body_exited(body):
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
