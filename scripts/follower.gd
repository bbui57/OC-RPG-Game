extends CharacterBody3D  # Ensure it’s a character with movement capability

@export var stop_distance: float = 1.0  # Prevent overcrowding

@onready var anim = $AnimatedSprite3D
@onready var nav = $NavigationAgent3D

var player  # Reference to the selected character
var speed = 100
var gravity: float = 9.8
var facing = "front"
var update_timer = 0.0
var update_interval = 0.5

func _ready():
	anim = get_node("AnimatedSprite3D")
	nav = get_node("NavigationAgent3D")
	player = get_tree().get_first_node_in_group("player")  # Find the player automatically
	nav.path_desired_distance = 0.5
	nav.target_desired_distance = 2.0
	velocity.y = -gravity
	

func _physics_process(delta):
	if anim == null:
		anim = get_node_or_null("AnimatedSprite3D")
	if nav == null:
		nav = get_node_or_null("NavigationAgent3D")
		
	if not is_on_floor():
			velocity.y -= gravity * speed * delta
	if player:
		# Controls
		if not is_on_floor():
			velocity.y -= gravity * speed * delta
		
		if Engine.time_scale == 0:
			return
			
		update_timer += delta
		if update_timer >= update_interval:
			update_timer = 0.0
			nav.set_target_position(player.position)
		
		if nav.is_navigation_finished():
			velocity = Vector3.ZERO
		else:
			var next_point = nav.get_next_path_position()
			var direction = (next_point - position).normalized()
			velocity = direction * speed * delta
		
		if velocity.length() > 0:
			if abs(velocity.x) > abs(velocity.z):
				facing = "right" if velocity.x > 0 else "left"
			else:
				facing = "front" if velocity.z > 0 else "back"
			
			anim.play("move_" + facing)
		else:
			anim.play("stand_" + facing)
				
	# Boundary Setting
	var grid_size: int = 4  # Set the grid dimensions
	var cell_size: float = 1.0  # Define individual cell size
	var min_x = -grid_size * cell_size
	var max_x = grid_size * cell_size
	var min_z = -grid_size * cell_size
	var max_z = grid_size * cell_size
	
	var target_position = position + Vector3(velocity.x * delta, velocity.y * delta, velocity.z * delta)

	# Constrain movement to grid boundaries
	target_position.x = clamp(target_position.x, min_x, max_x)
	target_position.z = clamp(target_position.z, min_z, max_z)

	position = target_position  # Apply restricted movement

	move_and_slide()
