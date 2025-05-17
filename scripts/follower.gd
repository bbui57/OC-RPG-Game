extends CharacterBody2D  # Ensure it’s a character with movement capability

@export var stop_distance: float = 1.0  # Prevent overcrowding

@onready var anim = $AnimatedSprite2D

var player  # Reference to the selected character
var speed = 200
var facing = "front"
var update_timer = 0.0
var update_interval = 0.5
var follower_index

func _ready():
	player = get_tree().get_first_node_in_group("player")  # Find the player automatically
	set_collision_layer(3)
	set_collision_mask(1)
	collision_layer &= ~2
	update_index()

func _physics_process(delta):
	
	z_index = max(position.y * 1.5, 1)
	
	velocity = Vector2.ZERO
	
	if anim == null:
		anim = get_node_or_null("AnimatedSprite2D")
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
	var distanceToTarget = 20
	var targetPosition = player.position - Vector2(0, -9)
	if position.distance_to(targetPosition) > distanceToTarget * follower_index:
		var direction = (targetPosition - position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

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
	
	for follower in get_tree().get_nodes_in_group("follower"):
		follower_index = follower.get_index()

func open_dialogue():
	var dialogue_ui = get_tree().get_root().find_child("Dialogue", true, false)
	dialogue_ui.visible = true
