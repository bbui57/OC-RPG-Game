extends CharacterBody3D

@export var speed = 100
var gravity: float = 50.0
var jump = 50

@onready var anim = $AnimatedSprite3D

#Map boundaries
var grid_size: int = 10
var cell_size: float = 1.0
var square = grid_size * cell_size
var min_x = square
var max_x = square
var min_z = square
var max_z = square

func _physics_process(delta):
	
	# Controls
	velocity = Vector3.ZERO
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Engine.time_scale == 0:
		return
		
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	if Input.is_action_pressed("move_down"):
		velocity.z = 1
	if Input.is_action_pressed("move_up"):
		velocity.z = -1
	
	# Handle multiple movement inputs
	var input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if abs(input.x) > abs(input.y):
		input.y = 0
	else:
		input.x = 0

	if velocity.length() > 0:
		velocity.x = input.x * speed * delta
		velocity.z = input.y * speed * delta
		if velocity.x > 0:
			anim.play("move_right")
		if velocity.x < 0:
			anim.play("move_left")
		if velocity.z > 0:
			anim.play("move_down")
		if velocity.z < 0:
			anim.play("move_up")
	else:
		if Input.is_action_just_released("move_right"):
			anim.play("stand_right")
		if Input.is_action_just_released("move_left"):
			anim.play("stand_left")
		if Input.is_action_just_released("move_down"):
			anim.play("stand_front")
		if Input.is_action_just_released("move_up"):
			anim.play("stand_back")
	
	# Boundary Setting
	var grid_size: int = 4  # Set the grid dimensions
	var cell_size: float = 1.0  # Define individual cell size
	var min_x = -grid_size * cell_size
	var max_x = grid_size * cell_size
	var min_z = -grid_size * cell_size
	var max_z = grid_size * cell_size
	
	var target_position = position + Vector3(velocity.x * delta, 0, velocity.z * delta)

	# Constrain movement to grid boundaries
	target_position.x = clamp(target_position.x, min_x, max_x)
	target_position.z = clamp(target_position.z, min_z, max_z)

	position = target_position  # Apply restricted movement

	
	move_and_slide()
