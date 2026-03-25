extends GutTest

var player: Player

func before_each() -> void:
	#player = autoqfree(load("res://player.tscn").instantiate())
	player = load("res://player.tscn").instantiate()
	add_child(player)
	player.state = Player.State.RESTING
	

func after_each() -> void:
	player.queue_free()

# ============================

func test_falling_with_crouch_input_leads_to_fast_falling_state() -> void:
	player.on_floor = false
	player.velocity = Vector2(0, 100)
	player.state = Player.State.FALLING
	player.inputs.crouch = true
	player._check_for_physics_transitions()
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.FAST_FALLING)


func test_falling_causes_jumping_animation() -> void:
	player.on_floor = false
	player.state = Player.State.FALLING
	player.inputs.crouch = false
	player._check_for_physics_transitions()
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.get_node("AnimatedSprite2D").animation, "jumping")


func test_jump_from_resting_causes_jumpsquat_state() -> void:
	player.state = Player.State.RESTING
	player.inputs.jump = true
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.JUMPSQUAT)


func test_jump_input_from_resting_causes_jumpsquat_state() -> void:
	player.inputs.jump = true
	player.state = Player.State.RESTING
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.JUMPSQUAT)


func test_jump_input_from_dashing_causes_jumpsquat_state() -> void:
	player.inputs.jump = true
	player.state = Player.State.DASHING
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.JUMPSQUAT)


func test_jump_input_from_running_causes_jumpsquat_state() -> void:
	player.inputs.jump = true
	player.state = Player.State.RUNNING
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.JUMPSQUAT)


func test_jump_input_from_dash_release_causes_jumpsquat_state() -> void:
	player.inputs.jump = true
	player.state = Player.State.DASH_RELEASE
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.JUMPSQUAT)


func test_jump_while_run_turnaround_causes_jumpsquat_state() -> void:
	player.state = Player.State.RUN_TURNAROUND
	player.inputs.jump = true
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.JUMPSQUAT)


func test_jump_while_walking_causes_jumpsquat_state() -> void:
	player.state = Player.State.WALKING
	player.inputs.jump = true
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.JUMPSQUAT)


func test_jumpsquat_causes_jumpsquat_animation() -> void:
	player.get_node("AnimatedSprite2D").animation = "jumping"
	player.state = Player.State.JUMPSQUAT
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.get_node("AnimatedSprite2D").animation, "jumpsquat")


func test_jumpsquat_ending_causes_jumping_state() -> void:
	player.state = Player.State.JUMPSQUAT
	player.jumpsquat_frame_count = player.JUMPSQUAT_FRAMES
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.JUMPING)
	assert_true(player.velocity.y < 0)


func test_jumpsquat_frame_count_above_jumpsquat_frames_causes_jumping_state() -> void:
	player.state = Player.State.JUMPSQUAT
	player.jumpsquat_frame_count = player.JUMPSQUAT_FRAMES + 10
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.JUMPING)
	assert_true(player.velocity.y < 0)


func test_y_velocity_with_no_input_leads_to_slowing_by_gravity() -> void:
	player.velocity.y = -100
	player.on_floor = false
	player.state = Player.State.JUMPING
	player.gravity_vector = Vector2(0, player.GRAVITY)
	player._apply_gravity(1)
	
	assert_true(player.velocity.y > -100)


func test_jump_while_input_opposes_facing_direction_causes_backflip() -> void:
	player.velocity.x = 100
	player.state = Player.State.JUMPSQUAT
	player.jumpsquat_frame_count = player.JUMPSQUAT_FRAMES
	player.inputs.axis = -1.0
	player.inputs.direction = -1
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x < 0 )
