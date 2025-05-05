extends CharacterBody3D

@export var speed = 400

var character
var anim

func _ready():
		
	var character_scene = load(Global.characters[Global.selected_character])
	var character_instance = character_scene.instantiate() # Create instance
	
	add_child(character_instance)
	
	character = get_child(0)
	anim = character.get_node("AnimatedSprite3D")



func _process(delta):
	if Engine.time_scale == 0:
		return
		
	velocity = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	if Input.is_action_pressed("move_down"):
		velocity.z = 1
	if Input.is_action_pressed("move_up"):
		velocity.z = -1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed * delta
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
	
	move_and_slide()
	
