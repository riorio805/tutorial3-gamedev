extends KinematicBody2D


export (int) var speed = 500
export (int) var GRAVITY = 1500
export (int) var jump_speed = 700
export (int) var extra_jumps = 1
export (float) var coyote_time = 0.15
export (float) var dash_delay = 0.15
export (float) var dash_mod = 1.6

onready var collision_shape = $CollisionShape2D
onready var sprite = $Sprite
onready var explode_sprite = $AnimatedSprite
var velocity = Vector2()
var jumps_left = extra_jumps
var crouch_offset

var time_since_left = 0.0
var time_since_right = 0.0
var time_since_grounded = 0.0

# flags
var crouch = false
var uncrouch = false
var dashing = false
var stopped = false

const UP = Vector2(0,-1)


func _ready():
	crouch_offset = collision_shape.shape.extents.y / 2
	pass


func get_input():	
	velocity.x = 0
	
	if time_since_left <= dash_delay and Input.is_action_just_pressed('ui_left'):
		dashing = true
	elif time_since_right <= dash_delay and Input.is_action_just_pressed('ui_right'):
		dashing = true
	
	if not (Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_right')):
		dashing = false
		
	if Input.is_action_pressed('ui_right'):
		time_since_right = 0
		if dashing:
			velocity.x += speed * dash_mod
		else:
			velocity.x += speed
	if Input.is_action_pressed('ui_left'):
		time_since_left = 0
		if dashing:
			velocity.x -= speed * dash_mod
		else:
			velocity.x -= speed
	
	if (jumps_left > 0 and Input.is_action_just_pressed('ui_up')) or \
		(is_on_floor() and Input.is_action_pressed("ui_up")):
		velocity.y = UP.y * jump_speed
		if time_since_grounded > coyote_time:
			jumps_left -= 1
	
	if Input.is_action_just_pressed('ui_down'):
		crouch = true
	elif Input.is_action_just_released('ui_down'):
		uncrouch = true
	
	if stopped:
		velocity = Vector2()


func _physics_process(delta):
	if stopped:
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
		if is_on_floor():
			position.y += crouch_offset
		collision_shape.scale.y = 0.5
		sprite.scale.y = 0.5
	elif uncrouch:
		uncrouch = false
		if is_on_floor():
			position.y -= crouch_offset
		collision_shape.scale.y = 1
		sprite.scale.y = 1
	
	velocity.y += delta * GRAVITY
	velocity = move_and_slide(velocity, UP)
	
	# check collisions with spike	
	for i in get_slide_count():
		var collided = get_slide_collision(i)
		if collided.collider.name == "KillTile":
			explode_sprite.play_explode()
			sprite.visible = false
			stopped = true






