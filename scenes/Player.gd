extends KinematicBody2D

export(int) var speed = 500
export(int) var gravity = 1500
export(int) var jump_speed = 700
export(int) var extra_jumps = 1
export(float) var coyote_time = 0.15
export(float) var dash_delay = 0.15
export(float) var dash_mod = 1.5
export(float) var crouch_mod = 0.6

onready var collision_shape = $CollisionShape2D
onready var sprite = $PlayerSprite
onready var explode_sprite = $ExplodeSprite
onready var explode_audio = $ExplodeSFX
onready var win_audio = $CelebrateSFX
onready var spawn_pos = position

var velocity = Vector2()
var jumps_left = extra_jumps
var crouch_offset

var time_since_left = 0.0
var time_since_right = 0.0
var time_since_grounded = 0.0
var time_since_dead = 0.0

# flags
var crouch = false
var uncrouch = false
var crouching = false
var dashing = false
var stopped = false

const UP = Vector2(0, -1)


func reset():
	position = spawn_pos
	explode_sprite.stop_anim()
	explode_audio.stop()
	sprite.visible = true
	velocity = Vector2()
	stopped = false
	uncrouch = true
	dashing = false
	pass


func _ready():
	crouch_offset = collision_shape.shape.extents.y / 2


func update_animation():
	if velocity.x > 0:
		sprite.change_direction(Enums.Direction.RIGHT)
	elif velocity.x < 0:
		sprite.change_direction(Enums.Direction.LEFT)

	if velocity.y < 0:
		sprite.change_state(Enums.PlayerAnimState.JUMPING)
	elif velocity.y > 0:
		sprite.change_state(Enums.PlayerAnimState.FALLING)

	if is_on_floor():
		if abs(velocity.x) > 1e-4:
			if dashing:
				sprite.change_state(Enums.PlayerAnimState.DASHING)
			else:
				sprite.change_state(Enums.PlayerAnimState.WALKING)
		else:
			sprite.change_state(Enums.PlayerAnimState.IDLE)


func get_input():
	if stopped:
		velocity = Vector2()
		return
	#velocity.x = 0

	if is_on_floor():
		if time_since_left <= dash_delay and Input.is_action_just_pressed("ui_left"):
			dashing = true
		elif time_since_right <= dash_delay and Input.is_action_just_pressed("ui_right"):
			dashing = true

		if not (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
			dashing = false

	var speed_mod = 1
	if dashing:
		speed_mod *= dash_mod
	if crouching:
		speed_mod *= crouch_mod

	if Input.is_action_pressed("ui_right"):
		time_since_right = 0
		velocity.x += speed * speed_mod
	if Input.is_action_pressed("ui_left"):
		time_since_left = 0
		velocity.x -= speed * speed_mod

	if (
		(jumps_left > 0 and Input.is_action_just_pressed("ui_up"))
		or (is_on_floor() and Input.is_action_pressed("ui_up"))
	):
		velocity.y = UP.y * jump_speed
		if time_since_grounded > coyote_time:
			jumps_left -= 1

	if Input.is_action_just_pressed("ui_down"):
		crouch = true
	elif Input.is_action_just_released("ui_down"):
		uncrouch = true


func die_now():
	explode_sprite.play_explode()
	explode_audio.play()
	sprite.visible = false
	stopped = true
	time_since_dead = 0
	pass


func _physics_process(delta):
	if stopped:
		time_since_dead += delta
		if time_since_dead > 1:
			reset()
		return

	time_since_left += delta
	time_since_right += delta
	time_since_grounded += delta
	get_input()

	if is_on_floor():
		time_since_grounded = 0
		jumps_left = extra_jumps

	if crouch:
		crouch = false
		crouching = true
		if is_on_floor():
			position.y += crouch_offset
		collision_shape.scale.y = 0.5
		sprite.scale.y = 0.5
	elif uncrouch:
		uncrouch = false
		crouching = false
		if is_on_floor():
			position.y -= crouch_offset
		collision_shape.scale.y = 1
		sprite.scale.y = 1

	velocity.y += delta * gravity
	velocity.x *= 0.6
	velocity = move_and_slide(velocity, UP)

	# check collisions with spike
	for i in get_slide_count():
		var collided = get_slide_collision(i)
		if collided.collider.name == "KillTile":
			die_now()


func _process(_delta):
	update_animation()
	pass


func _on_body_entered(body, checkpoint):
	if body.name == "Player":
		body.spawn_pos = checkpoint.position + Vector2(0, 105)
		if checkpoint.name == "GoalCheckpoint":
			win_audio.play()
