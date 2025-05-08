extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.increase_score(1)
		get_tree().queue_delete(self)
