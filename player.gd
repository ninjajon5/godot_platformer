class_name Player
extends CharacterBody2D

# constants
const SPEED: float = 600.0
const FRICTION: float = 50.0
const GRAVITY: float = 30.0
const JUMP_VELOCITY: float = -600.0
const FAST_FALLING_MULTIPLIER: int = 2
const DASHING_FRAMES: int = 15
const SMASH_STICK_FRAMES: int = 8
const SMASH_STICK_AXIS: float = 0.95

# state tracking
enum State { 
	RESTING, 
	RUNNING, 
	DASHING, 
	DASH_RELEASE, 
	JUMPING, 
	FALLING, 
	FAST_FALLING 
}
var state: State
var dashing_frame_count: int = 0

# input attributes
var jump_inputted: bool
var crouch_inputted: bool
var left_inputted: bool
var right_inputted: bool
var input_axis: float
var input_direction: float
var smash_stick_left_frame_count: int = 0
var smash_stick_right_frame_count: int = 0
var smashing_stick: bool

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
	input_axis = Input.get_axis("left", "right")
	input_direction = sign(input_axis)
	_check_for_smash_stick()


func _check_for_physics_transitions() -> void:
	if not on_floor and velocity.y >= 0 and state != State.FAST_FALLING:
		state = State.FALLING
	elif on_floor and velocity.x == 0:
		state = State.RESTING
	elif state in [State.FALLING, State.FAST_FALLING] and on_floor:
		state = State.RUNNING


func _apply_inputs_depending_on_state() -> void:
	match state:
		State.RESTING: _apply_inputs_to_resting_state()
		State.RUNNING: _apply_inputs_to_running_state()
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


func _check_for_smash_stick() -> void:	
	if input_axis >= SMASH_STICK_AXIS:
		if smash_stick_right_frame_count <= SMASH_STICK_FRAMES:
			smashing_stick = true
	elif input_axis <= -SMASH_STICK_AXIS:
		if smash_stick_left_frame_count <= SMASH_STICK_FRAMES:
			smashing_stick = true
	else:
		smashing_stick = false
		_update_smash_stick_frame_counts()


func _update_smash_stick_frame_counts() -> void:
	if input_direction > 0.0:
		smash_stick_left_frame_count = 0
		smash_stick_right_frame_count += 1
	elif input_direction < 0.0:
		smash_stick_left_frame_count += 1
		smash_stick_right_frame_count = 0
	else:
		smash_stick_left_frame_count = 0
		smash_stick_right_frame_count = 0


func _apply_inputs_to_running_state() -> void:
	if input_direction:
		_run()
	else:
		_apply_friction()
		
	if jump_inputted:
		_jump()


func _apply_inputs_to_dashing_state() -> void:
	if input_direction:
		if dashing_frame_count <= DASHING_FRAMES:
			_dash()
		else:
			_run()
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


func _run() -> void:
	state = State.RUNNING
	$AnimatedSprite2D.play("walking")
	_flip_animation_based_on_input_direction()


func _dash() -> void:
	state = State.DASHING
	
	if _input_opposes_direction():
		dashing_frame_count = 0

	velocity.x = input_direction * SPEED
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
