extends CharacterBody2D

#player movement variables
@export var speed = 100
@export var gravity = 200
@export var jump_height = -150
var is_jumping = false

#movement and physics
func _physics_process(delta):
	# vertical movement velocity (down)
	velocity.y += gravity * delta
	# horizontal movement processing (left, right)
	horizontal_movement()
	#applies movement
	move_and_slide() 
	#applies animations
	if !Global.is_attacking || !Global.is_climbing:
		player_animations()

func horizontal_movement():
	# if keys are pressed it will return 1 for ui_right, -1 for ui_left, and 0 for neither
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed

#animations
func player_animations():
	#on left (add is_action_just_released so you continue running after jumping)
	if (Input.is_action_pressed("ui_left") || Input.is_action_just_released("ui_jump")) && Global.is_jumping == false:
		$AnimatedSprite2D.flip_h = true
		if is_on_floor():
			$AnimatedSprite2D.play("run")

	#on right (add is_action_just_released so you continue running after jumping)
	if (Input.is_action_pressed("ui_right") || Input.is_action_just_released("ui_jump")) && Global.is_jumping == false:
		$AnimatedSprite2D.flip_h = false
		if is_on_floor():
			$AnimatedSprite2D.play("run")
		
	#on idle if nothing is being pressed
	if !Input.is_anything_pressed():
		$AnimatedSprite2D.play("idle")

#singular input captures
func _input(event):
	#on attack
	if event.is_action_pressed("ui_attack"):
		Global.is_attacking = true
		$AnimatedSprite2D.play("attack")
	#on jump
	if event.is_action_pressed("ui_jump") and is_on_floor():
		velocity.y = jump_height
		$AnimatedSprite2D.play("jump")
		Global.is_jumping = true
		
	 #on climbing ladders
	if Global.is_climbing == true:
		if !Input.is_anything_pressed():
			$AnimatedSprite2D.play("idle")

		if Input.is_action_pressed("ui_up"):
			$AnimatedSprite2D.play("climb") 
			gravity = 100
			velocity.y = -160
			Global.is_jumping = true

	#reset gravity
	else:
		gravity = 200
		Global.is_climbing = false
		Global.is_jumping = false
		
func _on_animated_sprite_2d_animation_finished() -> void:
	Global.is_attacking = false
	Global.is_climbing = false
