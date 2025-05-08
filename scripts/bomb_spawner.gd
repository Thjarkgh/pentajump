extends Node2D

var bomb = preload("res://scenes/Bomb.tscn")

@export var inverted = false

#references to our scene, PathFollow2D path, and AnimationPlayer path
var current_scene_path
var bomb_path
var bomb_animation

 #when it's loaded into the scene
func _ready():
	#default animation on load
	$AnimatedSprite2D.play("default")   
	#initiates paths
	current_scene_path = "/root/" + Global.current_scene_name #+ "/" #current scene
	bomb_path = self.get_parent().find_child("BombPath").find_child("Path2D").find_child("PathFollow2D") # get_node(current_scene_path + "/Spawners/"+path+"/BombPath/Path2D/PathFollow2D") #PathFollow2D
	bomb_animation = self.get_parent().find_child("BombPath").find_child("Path2D").find_child("AnimationPlayer") # get_node(current_scene_path + "/Spawners/" + path + "/BombPath/Path2D/AnimationPlayer") #AnimationPlayer
 	#starts bomb movement
	#bomb_animation.play("bomb_movement")

#spawns bomb instance    
func shoot():
	#play cannon shoot animation each time the function is fired off
	$AnimatedSprite2D.play("spawn")
	#returns spawned bomb
	#bomb_animation.play("bomb_movement")
	var spawned_bomb = bomb.instantiate()
	spawned_bomb.inverted = inverted
	return spawned_bomb

func _on_timer_timeout() -> void:
	#reset animation before shooting    
	$AnimatedSprite2D.play("default")
	#spawns a bomb onto our path if there are no bombs available
	#if ready:
	if bomb_path.get_child_count() <= 0:
		bomb_path.add_child(shoot())
#	else:
		# Clear all existing bombs  
		#if Global.is_bomb_moving == false:
	#		for bombs in bomb_path.get_children():
#				bomb_path.remove_child(bombs)#
#				bombs.queue_free()
#				bomb_animation.stop()
		
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "spawn":
		$AnimatedSprite2D.play("default")
