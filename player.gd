class_name Player
extends CharacterBody2D

# constants
const SPEED := 600.0
const ACCELERATION := 100.0
const FRICTION := 100.0
const JUMP_VELOCITY := -400.0
const FAST_FALLING_MULTIPLIER := 2

# state tracking
enum State { RESTING, WALKING, JUMPING, FALLING }
var state: State = State.RESTING

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
var gravity: Vector2


func _physics_process(delta: float) -> void:
	_read_inputs()
	_read_physics()
	_update_state()
	_apply_physics(delta)
	_update_animation()
	

func _read_inputs() -> void:
	jump_inputted = Input.is_action_just_pressed("jump")
	crouch_inputted = Input.is_action_just_pressed("crouch")
	left_inputted = Input.is_action_just_pressed("left")
	right_inputted = Input.is_action_just_pressed("right")
	input_direction = Input.get_axis("left", "right")


func _read_physics() -> void:
	on_floor = is_on_floor()
	gravity = get_gravity()


func _update_state() -> void:
	if not on_floor:
		state = State.JUMPING if velocity.y < 0 else State.FALLING
	else:
		state = State.RESTING if velocity.x == 0 else State.WALKING


func _apply_physics(delta: float) -> void:
	_apply_gravity(delta)
	
	if jump_inputted and on_floor:
		_jump()
	
	if on_floor:
		_apply_on_ground_physics(delta)

	move_and_slide()
	

func _update_animation() -> void:
	match state:
		State.RESTING: $AnimatedSprite2D.play("resting")
		State.WALKING: $AnimatedSprite2D.play("walking")
		State.JUMPING: $AnimatedSprite2D.play("jumping")
		State.FALLING: $AnimatedSprite2D.play("jumping")
		
	if on_floor and input_direction:
		_flip_animation_based_on_input_direction()


func _apply_gravity(delta: float) -> void:
	if not on_floor:
		if crouch_inputted and velocity.y >= 0 and not fast_falling:
			fast_falling = true
		if fast_falling:
			gravity_multiplier *= FAST_FALLING_MULTIPLIER
		velocity += gravity * delta * gravity_multiplier
		

func _jump() -> void:
	gravity_multiplier = 1
	fast_falling = false
	velocity.y = JUMP_VELOCITY
	

func _apply_on_ground_physics(delta: float) -> void:
	if input_direction:
		_move_on_ground(delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
		
		
func _move_on_ground(delta: float) -> void:
	velocity.x = move_toward(velocity.x, input_direction * SPEED, ACCELERATION * delta)
	

func _flip_animation_based_on_input_direction() -> void:
	$AnimatedSprite2D.flip_h = _should_flip_animation()
		

func _should_flip_animation() -> bool:
	return input_direction < 0
