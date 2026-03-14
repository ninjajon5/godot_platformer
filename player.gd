extends CharacterBody2D


const SPEED := 600.0
const ACCELERATION := 100.0
const FRICTION := 100.0
const JUMP_VELOCITY := -400.0
const FAST_FALLING_MULTIPLIER := 2

var fast_falling: bool = false
var gravity_multiplier: int = 1


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_jump()

	var direction := Input.get_axis("move_left", "move_right")
	if is_on_floor():
		_apply_on_ground_physics(direction)

	move_and_slide()
	
	
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if Input.is_action_just_pressed("crouch") and velocity.y >= 0 and not fast_falling:
			fast_falling = true
		if fast_falling:
			gravity_multiplier *= FAST_FALLING_MULTIPLIER
		velocity += get_gravity() * delta * gravity_multiplier
		

func _jump() -> void:
	gravity_multiplier = 1
	fast_falling = false
	velocity.y = JUMP_VELOCITY
	$AnimatedSprite2D.play("jumping")
	

func _apply_on_ground_physics(direction: float) -> void:
	if direction:
		_move_on_ground(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
		$AnimatedSprite2D.play("resting")
		

func _move_on_ground(direction: float) -> void:
	velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION)
	if direction > 0:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	$AnimatedSprite2D.play("walking")
