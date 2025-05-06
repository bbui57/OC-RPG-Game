extends CharacterBody3D

@export var speed: float = 50.0
@export var gravity: float = 50.0
@export var jump: float = 20.0

@onready var anim = $AnimatedSprite3D

var facing = "front"

func _ready():
	anim = get_node("AnimatedSprite3D")

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
	
	# Boundary Setting
#	var grid_size: int = 4  # Set the grid dimensions
#	var cell_size: float = 1.0  # Define individual cell size
#	var min_x = -grid_size * cell_size
#	var max_x = grid_size * cell_size
#	var min_z = -grid_size * cell_size
#	var max_z = grid_size * cell_size
#	var target_position = position + Vector3(velocity.x * delta, 0, velocity.z * delta)
#	# Constrain movement to grid boundaries
#	target_position.x = clamp(target_position.x, min_x, max_x)
#	target_position.z = clamp(target_position.z, min_z, max_z)
#	position = target_position  # Apply restricted movement

	if position.y < -1:
		position.y = 3
	move_and_slide()
