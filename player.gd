class_name Player
extends CharacterBody2D

# constants
const SPEED: float = 800.0
const ACCELERATION: float = 100.0
const FRICTION: float = 100.0
const GRAVITY: float = 30.0
const JUMP_VELOCITY: float = -600.0
const FAST_FALLING_MULTIPLIER: int = 2
const DASHING_FRAMES: int = 30

# state tracking
enum State { RESTING, WALKING, DASHING, JUMPING, FALLING }
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
var gravity_multiplier: int = 1
var gravity_vector: Vector2


func _physics_process(_delta: float) -> void:
	_read_inputs()
	_read_physics()
	_update_state()
	_apply_physics()
	_update_animation()
	

func _read_inputs() -> void:
	jump_inputted = Input.is_action_just_pressed("jump")
	crouch_inputted = Input.is_action_just_pressed("crouch")
	left_inputted = Input.is_action_just_pressed("left")
	right_inputted = Input.is_action_just_pressed("right")
	input_direction = Input.get_axis("left", "right")


func _read_physics() -> void:
	on_floor = is_on_floor()
	gravity_vector = Vector2(0, GRAVITY)


func _update_state() -> void:
	if not on_floor:
		state = State.JUMPING if velocity.y < 0 else State.FALLING
	else:
		if velocity.x == 0:
			state = State.RESTING
		else:
			state = State.WALKING if dashing_frame_count > DASHING_FRAMES else State.DASHING


func _apply_physics() -> void:
	if on_floor:
		_apply_on_ground_physics()
	else:
		_apply_gravity()
	
	if jump_inputted and _can_jump():
		_jump()

	move_and_slide()
	

func _update_animation() -> void:
	match state:
		State.RESTING: $AnimatedSprite2D.play("resting")
		State.WALKING: $AnimatedSprite2D.play("walking")
		State.JUMPING: $AnimatedSprite2D.play("jumping")
		State.FALLING: $AnimatedSprite2D.play("jumping")
		
	if on_floor and input_direction:
		_flip_animation_based_on_input_direction()


func _apply_on_ground_physics() -> void:
	if input_direction:
		_move_on_ground()
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)


func _apply_gravity() -> void:
	if crouch_inputted and _can_fast_fall():
		fast_falling = true
	if fast_falling:
		gravity_multiplier *= FAST_FALLING_MULTIPLIER
	velocity += gravity_vector * gravity_multiplier
		

func _jump() -> void:
	gravity_multiplier = 1
	fast_falling = false
	velocity.y = JUMP_VELOCITY


func _move_on_ground() -> void:
	if state == State.DASHING:
		velocity.x = move_toward(velocity.x, input_direction * SPEED * 2, ACCELERATION * 2)
		dashing_frame_count += 1
	else:
		velocity.x = move_toward(velocity.x, input_direction * SPEED, ACCELERATION)


func _flip_animation_based_on_input_direction() -> void:
	$AnimatedSprite2D.flip_h = _should_flip_animation()


func _should_flip_animation() -> bool:
	return input_direction < 0


func _can_jump() -> bool:
	return state in [State.RESTING, State.WALKING]


func _can_fast_fall() -> bool:
	return not fast_falling and state == State.FALLING
