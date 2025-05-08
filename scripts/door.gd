extends Area2D

func _ready():
	#hide menu on load
	$UI/Menu.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		# pause game
		get_tree().paused = true
		# show menu
		$UI.visible = true
		$UI/Menu.visible = true
		# make modular value visible
		$AnimationPlayer.play("ui_visibility")  
		#hide the player's UI 
		#body.get_node("UI").visible = false 
		#get final values
		body.final_score_time_and_rating()
		# show player values
		$UI/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
		$UI/Menu/Container/Score/Value.text = str(Global.final_score)
		$UI/Menu/Container/Ranking/Value.text = str(Global.final_rating)

func _on_restart_button_pressed():
	#unpause scene
	get_tree().paused = false
	#hide menu
	$UI/Menu.visible = false
	# Restart current scene
	get_tree().reload_current_scene()
