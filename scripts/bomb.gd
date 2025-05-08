extends Area2D

var is_spawning = true
var speed = 100
@export var starting_direction = -1
var current_scene_path
var bomb_path
var bomb_animation
var marked_for_destruction = false


func _ready() -> void:
	#var path = self.get_parent().name;
	Global.is_bomb_moving = false
	$AnimatedSprite2D.play("spawn")
	current_scene_path = "/root/" + Global.current_scene_name #+ "/" #current scene
	bomb_path = self.get_parent() # get_node(current_scene_path + "/Spawners/" + path + "/BombPath/Path2D/PathFollow2D") #PathFollow2D
	bomb_animation = self.get_parent().get_parent().find_child("AnimationPlayer") # + "/AnimationPlayer") # get_node(current_scene_path + "/Spawners/" + path + "/BombPath/Path2D/AnimationPlayer") #AnimationPlayer
	$AnimatedSprite2D.flip_v = true
	bomb_animation.stop()

func _on_timer_timeout() -> void:
	if is_spawning == true:
		is_spawning = false;
		$AnimatedSprite2D.play("walk")
		Global.is_bomb_moving = true
		bomb_animation.start("bomb_movement")
	else:
		if is_instance_valid(self):
			self.queue_free()
		


func _on_body_entered(body: Node2D) -> void:
	#if the bomb collides with the player, play the explosion animation and start the timer
	if body.name == "Player":
		$AnimatedSprite2D.play("attack")
		bomb_animation.pause()
		$Timer.start()
		body.take_damage()
		#Global.is_bomb_moving = false

	#if the bomb collides with our Level Tilemap (floor and walls). 
	if body.name.begins_with("Lava"):
		$AnimatedSprite2D.play("damage")
		$Timer.start()
		marked_for_destruction = true

func _on_animated_sprite_2d_animation_finished() -> void:
	is_spawning = false # Replace with function body.
	$AnimatedSprite2D.play("walk")
	Global.is_bomb_moving = true
	bomb_animation.play("bomb_movement")
	if marked_for_destruction == true:
		Global.is_bomb_moving = false
	# velocity 
	#default animation on spawn
