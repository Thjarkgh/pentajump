extends Area2D

func _ready():
	$AnimatedSprite2D.play("moving")

func _on_body_entered(body: Node2D) -> void:
	# If the bomb collides with the player, play the explosion animation and disable spawning
	if body.name != "Shard" && !body.name.begins_with("@RigidBody2D@"):
		$AnimatedSprite2D.play("explode")
		#find_child("ShardEmitter").shatter()
		# Disable spawning in BoxSpawner
		Global.disable_spawning()
		if body.name == "Player":
			#deal damage
			body.take_damage()
		#else:
		#	queue_free()
		# If the bomb collides with our Wall scene, remove so that it can be respawned
		#if body.name.begins_with("Wall"):
			#queue_free()

#if the box's explode animation is playing, remove it from the scene
func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "explode":
		queue_free()
