extends AnimatedSprite


func play_explode():
	visible = true
	frame = 0
	play("explode")


func stop_anim():
	visible = false
	frame = 0
	stop()


func _on_AnimatedSprite_animation_finished():
	visible = false
	pass  # Replace with function body.
