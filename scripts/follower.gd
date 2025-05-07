extends CharacterBody3D  # Ensure it’s a character with movement capability

@export var stop_distance: float = 1.0  # Prevent overcrowding

@onready var anim = $AnimatedSprite3D
@onready var nav = $NavigationAgent3D
@onready var prompt = anim.get_node("UI")

var player  # Reference to the selected character
var speed = 100
var gravity: float = 9.8
var facing = "front"
var update_timer = 0.0
var update_interval = 0.5
var orbit_radius = 0.17
var bubble_offset = Vector3(0.7, 0.5, 0)

func _ready():
	anim = get_node("AnimatedSprite3D")
	nav = get_node("NavigationAgent3D")
	player = get_tree().get_first_node_in_group("player")  # Find the player automatically
	
	nav.path_desired_distance = 0.5
	nav.target_desired_distance = 2.0
	velocity.y = -gravity

func _physics_process(delta):
	velocity = Vector3.ZERO
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
			
		# Thought Bubble
		var camera_direction = (player.global_transform.origin - global_transform.origin).normalized()
		var angle = atan2(camera_direction.x, camera_direction.z)
		var offset_x = cos(angle) * orbit_radius
		var offset_z = sin(angle) * orbit_radius
		anim.get_node("UI").global_transform.origin = global_transform.origin + Vector3(offset_x, 0.15, offset_z) + bubble_offset
				
	move_and_slide()

func _input(event):
	if event.is_action_pressed("interact") and prompt.visible:
		get_tree().get_root().find_child("HUD", true, false).visible = false
		open_dialogue()

func open_dialogue():
	var dialogue_ui = get_tree().get_root().find_child("Dialogue", true, false)
	dialogue_ui.visible = true
