extends KinematicBody

const GRAVITY_VEC = Vector3(0, -15, 0)
const FLOOR_NORMAL = Vector3(0, 1, 0)
const SLOPE_SLIDE_STOP = 5.0
const WALK_SPEED = 5 # pixels/sec
const JUMP_SPEED = -6
const SIDING_CHANGE_SPEED = 1

var linear_vel = Vector3()

var anim = ""

onready var sprite = $Sprite

func _physics_process(delta):

	### MOVEMENT ###

	# Apply gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect if we are on floor - only works if called *after* move_and_slide
	var on_floor = is_on_floor()

	### CONTROL ###

	# Horizontal movement
	var target_speed = 0
	if Input.is_action_pressed("ui_left"):
		target_speed -= 1
	if Input.is_action_pressed("ui_right"):
		target_speed += 1

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	if on_floor and Input.is_action_just_pressed("ui_up"):
		linear_vel.y = -JUMP_SPEED
		#($SoundJump as AudioStreamPlayer2D).play()

	### ANIMATION ###

	var new_anim = "idle"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "running"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "running"
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
			sprite.scale.x = -1
		if Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
			sprite.scale.x = 1

		if linear_vel.y > 0:
			new_anim = "jumping"
		else:
			new_anim = "falling"

	if new_anim != anim:
		anim = new_anim
		sprite.play(anim)
		#($Anim as AnimationPlayer).play(anim)