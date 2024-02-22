extends AnimatedSprite

func play_explode():
	visible = true
	frame = 0
	play("explode")

func _on_explode_animation_finished():
	visible = false

func _process(_delta):
	pass
