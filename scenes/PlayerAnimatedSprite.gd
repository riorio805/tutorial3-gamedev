extends AnimatedSprite

var current_state = Enums.PlayerAnimState.IDLE
var facing_left = false


func change_state(state: int):
	if state == current_state:
		return

	current_state = state
	if state == Enums.PlayerAnimState.IDLE:
		play("idle")
	elif state == Enums.PlayerAnimState.WALKING:
		play("walking")
	elif state == Enums.PlayerAnimState.DASHING:
		play("dashing")
	elif state == Enums.PlayerAnimState.JUMPING:
		play("jumping")
	elif state == Enums.PlayerAnimState.FALLING:
		play("falling")


func change_direction(dir):
	flip_h = (dir == Enums.Direction.LEFT)
