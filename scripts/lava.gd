extends Area2D

#var off_timer = true

func _ready() -> void:
	$AnimatedSprite2D2.play("default2")


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bomb":
		body.queue_free()
	elif body.name == "Player": # && off_timer:
		body.set_burning(self.get_rid())


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		body.remove_burning(self.get_rid())


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == "Bomb":
		var other_shape_owner = area.shape_find_owner(area_shape_index)
		var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
		area.free()


func _on_timer_timeout() -> void:
	pass #off_timer = true
