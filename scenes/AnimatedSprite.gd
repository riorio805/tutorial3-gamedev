extends AnimatedSprite

func play_explode():
	visible = true
	frame = 0
	play("explode")

func _on_AnimatedSprite_animation_finished():
	visible = false
	pass # Replace with function body.
