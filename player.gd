class_name Player
extends CharacterBody2D

# constants
const SPEED: float = 800.0
const ACCELERATION: float = 100.0
const FRICTION: float = 100.0
const GRAVITY: float = 30.0
const JUMP_VELOCITY: float = -600.0
const FAST_FALLING_MULTIPLIER: int = 2
const DASHING_FRAMES: int = 10

# state tracking
enum State { RESTING, WALKING, DASHING, DASH_RELEASE, JUMPING, FALLING, FAST_FALLING }
var state: State = State.RESTING
var dashing_frame_count: int = 0

# input attributes
var jump_inputted: bool
var crouch_inputted: bool
var left_inputted: bool
var right_inputted: bool
var input_direction: float

# physics attributes
var on_floor: bool
var fast_falling: bool = false
var gravity_vector: Vector2


func _physics_process(_delta: float) -> void:
	_read_inputs()
	_read_physics()
	
	_check_for_physics_transitions()
	_apply_inputs_depending_on_state()
	
	move_and_slide()


func _read_physics() -> void:
	on_floor = is_on_floor()
	gravity_vector = Vector2(0, GRAVITY)


func _read_inputs() -> void:
	jump_inputted = Input.is_action_just_pressed("jump")
	crouch_inputted = Input.is_action_just_pressed("crouch")
	left_inputted = Input.is_action_just_pressed("left")
	right_inputted = Input.is_action_just_pressed("right")
	input_direction = Input.get_axis("left", "right")


func _check_for_physics_transitions() -> void:
	if not on_floor and velocity.y >= 0 and state != State.FAST_FALLING:
			state = State.FALLING
	elif on_floor and velocity.x == 0:
			state = State.RESTING


func _apply_inputs_depending_on_state() -> void:
	match state:
		State.RESTING: _apply_inputs_to_resting_state()
		State.WALKING: _apply_inputs_to_walking_state()
		State.DASHING: _apply_inputs_to_dashing_state()
		State.DASH_RELEASE: _apply_inputs_to_dash_release_state()
		State.JUMPING: _apply_inputs_to_jumping_state()
		State.FALLING: _apply_inputs_to_falling_state()
		State.FAST_FALLING: _apply_inputs_to_fast_falling_state()


func _apply_inputs_to_resting_state() -> void:
	if input_direction:
		_dash()
	else:
		_rest()
		
	if jump_inputted:
		_jump()


func _apply_inputs_to_walking_state() -> void:
	if input_direction:
		_walk()
	else:
		_apply_friction()
		
	if jump_inputted:
		_jump()


func _apply_inputs_to_dashing_state() -> void:
	if input_direction:
		if dashing_frame_count < DASHING_FRAMES:
			_dash()
		else:
			_walk()
	else:
		_dash_release()
		_apply_friction()
		
	if jump_inputted:
		_jump()


func _apply_inputs_to_dash_release_state() -> void:
	if input_direction and _input_opposes_direction():
		_dash()
	else:
		_apply_friction()
	
	if jump_inputted:
		_jump()


func _apply_inputs_to_jumping_state() -> void:
	_apply_gravity(1)


func _apply_inputs_to_falling_state() -> void:
	if crouch_inputted:
		state = State.FAST_FALLING
		_apply_gravity(FAST_FALLING_MULTIPLIER)
	else:
		_apply_gravity(1)
	$AnimatedSprite2D.play("jumping")


func _apply_inputs_to_fast_falling_state() -> void:
	_apply_gravity(FAST_FALLING_MULTIPLIER)


func _apply_gravity(gravity_multiplier: int) -> void:
	velocity += gravity_vector * gravity_multiplier
	$AnimatedSprite2D.play("jumping")


func _apply_friction() -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION)
		

func _rest() -> void:
	dashing_frame_count = 0
	$AnimatedSprite2D.play("resting")


func _walk() -> void:
	state = State.WALKING
	velocity.x = move_toward(velocity.x, input_direction * SPEED, ACCELERATION)
	$AnimatedSprite2D.play("walking")
	_flip_animation_based_on_input_direction()


func _dash() -> void:
	state = State.DASHING
	
	if _input_opposes_direction():
		velocity.x = 0	# pivot
	
	velocity.x = move_toward(velocity.x, input_direction * SPEED, ACCELERATION * 2)
	dashing_frame_count += 1
	
	$AnimatedSprite2D.play("resting")
	_flip_animation_based_on_input_direction()


func _dash_release() -> void:
	state = State.DASH_RELEASE
	dashing_frame_count = 0


func _jump() -> void:
	state = State.JUMPING
	fast_falling = false
	velocity.y = JUMP_VELOCITY
	$AnimatedSprite2D.play("jumping")


func _flip_animation_based_on_input_direction() -> void:
	$AnimatedSprite2D.flip_h = true if input_direction < 0 else false


func _input_opposes_direction() -> bool:
	return sign(input_direction) != sign(velocity.x) and input_direction != 0
