class_name Player
extends CharacterBody2D

# constants
const WALKING_SPEED: float = 400.0
const RUNNING_SPEED: float = 600.0
const FRICTION: float = 25.0
const ACCELERATION: float = 50.0
const GRAVITY: float = 30.0
const JUMP_VELOCITY: float = -600.0
const FAST_FALLING_MULTIPLIER: int = 4
const DASHING_FRAMES: int = 15

# inputs
var inputs: InputReader = InputReader.new()

# state tracking
enum State { 
	RESTING,
	WALKING,
	RUNNING,
	RUN_TURNAROUND,
	DASHING, 
	DASH_RELEASE, 
	JUMPING, 
	FALLING, 
	FAST_FALLING 
}
const GROUNDED_INACTIONABLE_STATES: Array[State] = [State.RUN_TURNAROUND]
var state: State
var dashing_frame_count: int = 0

# physics attributes
var on_floor: bool
var fast_falling: bool = false
var gravity_vector: Vector2


func _physics_process(_delta: float) -> void:
	inputs.read_inputs()
	_read_physics()
	
	_check_for_physics_transitions()
	_apply_inputs_depending_on_state()
	
	move_and_slide()


func _read_physics() -> void:
	on_floor = is_on_floor()
	gravity_vector = Vector2(0, GRAVITY)


func _check_for_physics_transitions() -> void:
	if not on_floor and velocity.y >= 0 and state != State.FAST_FALLING:
		state = State.FALLING
	elif on_floor and velocity.x == 0:
		state = State.RESTING
	elif state in [State.FALLING, State.FAST_FALLING] and on_floor:
		state = State.RUNNING


func _apply_inputs_depending_on_state() -> void:
	_reset_inputs_if_inactionable()
	match state:
		State.RESTING: _apply_inputs_to_resting_state()
		State.WALKING: _apply_inputs_to_walking_state()
		State.RUNNING: _apply_inputs_to_running_state()
		State.RUN_TURNAROUND: _apply_inputs_to_run_turnaround_state()
		State.DASHING: _apply_inputs_to_dashing_state()
		State.DASH_RELEASE: _apply_inputs_to_dash_release_state()
		State.JUMPING: _apply_inputs_to_jumping_state()
		State.FALLING: _apply_inputs_to_falling_state()
		State.FAST_FALLING: _apply_inputs_to_fast_falling_state()


func _reset_inputs_if_inactionable() -> void:
	if state in GROUNDED_INACTIONABLE_STATES and inputs.smashing_stick:
		inputs.reset_smashing_stick()


func _apply_inputs_to_resting_state() -> void:
	if inputs.direction:
		if inputs.smashing_stick:
			_dash()
		else:
			_walk()
	else:
		_rest()
		
	if inputs.jump:
		_jump()


func _apply_inputs_to_walking_state() -> void:
	if inputs.smashing_stick:
		_dash()
	else:
		_walk()


func _apply_inputs_to_running_state() -> void:
	if inputs.direction:
		if _input_opposes_direction():
			_run_turnaround()
		else:
			_run()
	else:
		_apply_friction()
		
	if inputs.jump:
		_jump()


func _apply_inputs_to_run_turnaround_state() -> void:
	_run_turnaround()
	if inputs.jump:
		_jump()


func _apply_inputs_to_dashing_state() -> void:
	if inputs.direction and inputs.smashing_stick:
		if dashing_frame_count <= DASHING_FRAMES:
			_dash()
		else:
			_run()
	else:
		_dash_release()
		_apply_friction()
		
	if inputs.jump:
		_jump()


func _apply_inputs_to_dash_release_state() -> void:
	if inputs.direction and _input_opposes_direction() and inputs.smashing_stick:
		_dash()
	else:
		_apply_friction()
	
	if inputs.jump:
		_jump()


func _apply_inputs_to_jumping_state() -> void:
	_apply_gravity(1)


func _apply_inputs_to_falling_state() -> void:
	if inputs.crouch:
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
	velocity.x = move_toward(velocity.x, WALKING_SPEED * inputs.axis, ACCELERATION)
	$AnimatedSprite2D.play("walking")
	_flip_animation_based_on_direction()


func _run() -> void:
	state = State.RUNNING
	$AnimatedSprite2D.play("walking")
	_flip_animation_based_on_direction()


func _run_turnaround() -> void:
	if state != State.RUN_TURNAROUND:
		state = State.RUN_TURNAROUND
		inputs.smashing_stick = false
		_flip_animation_based_on_direction()
	_apply_friction()


func _dash() -> void:
	state = State.DASHING
	
	if _input_opposes_direction():
		dashing_frame_count = 0

	velocity.x = inputs.direction * RUNNING_SPEED
	dashing_frame_count += 1
	
	$AnimatedSprite2D.play("resting")
	_flip_animation_based_on_direction()


func _dash_release() -> void:
	state = State.DASH_RELEASE
	dashing_frame_count = 0


func _jump() -> void:
	state = State.JUMPING
	fast_falling = false
	velocity.y = JUMP_VELOCITY
	$AnimatedSprite2D.play("jumping")


func _flip_animation_based_on_direction() -> void:
	$AnimatedSprite2D.flip_h = true if inputs.direction < 0 else false


func _input_opposes_direction() -> bool:
	return sign(inputs.direction) != sign(velocity.x) and inputs.direction != 0
