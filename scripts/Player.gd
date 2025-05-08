extends CharacterBody2D

#custom signals
signal update_lives(lives, max_lives)

#player movement variables
@export var speed = 100
@export var gravity = 200
@export var jump_height = -150
var is_jumping = false
# Keep track of the last direction (1 for right, -1 for left, 0 for none)
var last_direction = 0
# Check the direction of the player's movement
var current_direction = 0
var max_lives = 3
var lives = 3
var score = 0
var level_start_time = Time.get_ticks_msec()
var is_hurt = false
var dying = false

func _ready():
	current_direction = -1

func _process(delta):
	if velocity.x > 0: # Moving right
		current_direction = 1
	elif velocity.x < 0: # Moving left
		current_direction = -1
	# If the direction has changed, play the appropriate animation
	if current_direction != last_direction:
		if $AnimationPlayer.is_playing():
			if $AnimationPlayer.current_animation == "move_left":
				$AnimationPlayer.play_section("move_right", $AnimationPlayer.current_animation_length - $AnimationPlayer.current_animation_position, $AnimationPlayer.current_animation_length);
			else:				
				$AnimationPlayer.play_section("move_left", $AnimationPlayer.current_animation_length - $AnimationPlayer.current_animation_position, $AnimationPlayer.current_animation_length);
				
		if current_direction == 1:
			# Play the right animation
			#$AnimationPlayer.play("move_right")
			#limits
			$Camera2D.limit_left = -150
			$Camera2D.limit_bottom = 705
			$Camera2D.limit_top = 40
			$Camera2D.limit_right = 2000

		elif current_direction == -1:
			# Play the left animation
			$AnimationPlayer.play("move_left")

			#limits
			$Camera2D.limit_left = -150
			$Camera2D.limit_bottom = 705
			$Camera2D.limit_top = 40
			$Camera2D.limit_right = 2000

		# Update the last_direction variable
		last_direction = current_direction
		
#movement and physics
func _physics_process(delta):
	# vertical movement velocity (down)
	velocity.y += gravity * delta
	# horizontal movement processing (left, right)
	horizontal_movement()
	#applies movement
	if !dying:
		move_and_slide() 
	
	#applies animations
	if !Global.is_attacking && !Global.is_climbing && !dying:
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
	if !dying:
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
	set_physics_process(true)
	is_hurt = false
	if $AnimatedSprite2D.animation == "death":
		# pause game
		get_tree().paused = true
		# show menu
		$GameOver/Menu.visible = true
		# make modular value visible
		$AnimationPlayer.play("ui_visibility")  
		#hide the player's UI 
		#$UI.visible = false
		#get final values
		final_score_time_and_rating()
		# show player values
		$GameOver/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
		$GameOver/Menu/Container/Score/Value.text = str(Global.final_score)
		$GameOver/Menu/Container/Ranking/Value.text = str(Global.final_rating)

func increase_score(amnt):
	score += amnt

func decrease_score(amnt):
	if amnt >= score:
		score = 0
	else:
		score -= amnt

# takes damage
func take_damage():
	#deduct and update lives    
	if lives > 0 && !dying:
		lives = lives - 1
		update_lives.emit(lives, max_lives)
		print(lives)
		#play damage animation
		$AnimatedSprite2D.play("damage")
		#allows animation to play
		set_physics_process(false)
		is_hurt = true
		#decrease score
		decrease_score(10)

	if lives <= 0:
		dying = true
		$AnimatedSprite2D.play("death")

func heal():
	if lives < max_lives:
		lives += 1

func final_score_time_and_rating():
	# Time to complete in seconds
	var time_taken = (Time.get_ticks_msec() - level_start_time) / 1000.0 # Convert to seconds
	var time_rounded = str(roundf(time_taken)) + " secs"
	# Rating based on time and score
	var rating = ""

	if time_taken <= 60 and score >= 10000:
		rating = "Master" # Exceptionally high score and fast completion
	elif time_taken <= 120 and score >= 5000:
		rating = "Pro" # Very high score and fast completion
	elif time_taken <= 180 and score >= 3000:
		rating = "Expert" # High score and moderately fast completion
	elif time_taken <= 240 and score >= 2000:
		rating = "Intermediate" # Good score and completion time
	elif time_taken <= 300 and score >= 1000:
		rating = "Amateur" # Decent score, but not very fast
	else:
		rating = "Beginner" # All other cases

	# Final results
	Global.final_score = score
	Global.final_time = time_rounded
	Global.final_rating = rating


func _on_restart_button_pressed() -> void:
	#unpause scene
	get_tree().paused = false
	#hide menu
	$GameOver/Menu.visible = false
	# Restart current scene
	get_tree().reload_current_scene()
	
var burners = []

func set_burning(rid) -> void:
	if burners.is_empty():
		take_damage()
		$BurnTimer.start()
		
	burners.append(rid)

func remove_burning(rid) -> void:
	burners = burners.filter(func(b): b != rid)
	if burners.is_empty():
		$BurnTimer.stop()


func _on_burn_timer_timeout() -> void:
	take_damage()
