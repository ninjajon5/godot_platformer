extends GutTest

var player: Player

func before_each() -> void:
	#player = autoqfree(load("res://player.tscn").instantiate())
	player = load("res://player.tscn").instantiate()
	add_child(player)
	player.state = Player.State.RESTING
	player.jump_inputted = false
	player.crouch_inputted = false
	player.left_inputted = false
	player.right_inputted = false
	player.input_direction = 0.0
	

func after_each() -> void:
	player.queue_free()
	

# =================================
# Tests should often be:
# 1. Define state
# 2. Define inputs
# 3. Run function to evaluate both
# 4. Assert on the result
# =================================


func test_resting_with_jump_inputted_causes_jumping_state() -> void:
	player.state = Player.State.RESTING
	player.jump_inputted = true
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.JUMPING)


func test_airborne_with_zero_velocity_causes_falling_state() -> void:
	player.on_floor = false
	player.velocity = Vector2(0, 0)
	player._check_for_physics_transitions()
	
	assert_eq(player.state, Player.State.FALLING)


func test_airborne_with_downwards_velocity_causes_falling_state() -> void:
	player.on_floor = false
	player.velocity = Vector2(0, 100)
	player._check_for_physics_transitions()
	
	assert_eq(player.state, Player.State.FALLING)


func test_falling_with_crouch_input_leads_to_fast_falling_state() -> void:
	player.on_floor = false
	player.velocity = Vector2(0, 100)
	player.state = Player.State.FALLING
	player.crouch_inputted = true
	player._check_for_physics_transitions()
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.FAST_FALLING)


func test_falling_causes_jumping_animation() -> void:
	player.on_floor = false
	player.state = Player.State.FALLING
	player.crouch_inputted = false
	player._check_for_physics_transitions()
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.get_node("AnimatedSprite2D").animation, "jumping")


func test_grounded_with_no_velocity_causes_resting_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(0, 0)
	player._check_for_physics_transitions()
	
	assert_eq(player.state, Player.State.RESTING)


func test_grounded_after_falling_with_no_x_velocity_and_no_input_causes_resting_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(0, 0)
	player.state = Player.State.FALLING
	player._check_for_physics_transitions()
	
	assert_eq(player.state, Player.State.RESTING)


func test_grounded_after_fast_falling_with_no_x_velocity_and_no_input_causes_resting_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(0, 0)
	player.state = Player.State.FAST_FALLING
	player._check_for_physics_transitions()
	
	assert_eq(player.state, Player.State.RESTING)


func test_grounded_after_falling_with_x_velocity_causes_RUNNING_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(10, 0)
	player.state = Player.State.FALLING
	player._check_for_physics_transitions()
	
	assert_eq(player.state, Player.State.RUNNING)


func test_grounded_after_fast_falling_with_x_velocity_causes_RUNNING_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(10, 0)
	player.state = Player.State.FAST_FALLING
	player._check_for_physics_transitions()
	
	assert_eq(player.state, Player.State.RUNNING)


func test_grounded_with_no_velocity_or_input_causes_resting_animation() -> void:
	player.on_floor = true
	player.velocity = Vector2(0, 0)
	player._check_for_physics_transitions()
	player._apply_inputs_depending_on_state()
	assert_eq(player.get_node("AnimatedSprite2D").animation, "resting")


func test_jump_from_resting_decreases_y_velocity() -> void:
	player.state = Player.State.RESTING
	player._jump()
	
	assert_true(player.velocity.y < 0)


func test_jump_input_from_resting_decreases_y_velocity() -> void:
	player.jump_inputted = true
	player.state = Player.State.RESTING
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.y < 0)


func test_jump_input_from_dashing_decreases_y_velocity() -> void:
	player.jump_inputted = true
	player.state = Player.State.DASHING
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.y < 0)


func test_jump_input_from_RUNNING_decreases_y_velocity() -> void:
	player.jump_inputted = true
	player.state = Player.State.RUNNING
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.y < 0)


func test_jump_input_from_dash_release_decreases_y_velocity() -> void:
	player.jump_inputted = true
	player.state = Player.State.DASH_RELEASE
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.y < 0)


func test_input_direction_from_resting_increases_x_velocity() -> void:
	player.state = Player.State.RESTING
	player.input_direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x > 0)


func test_input_direction_smashing_stick_from_resting_causes_dashing_state() -> void:
	player.state = Player.State.RESTING
	player.input_direction = 1
	player.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASHING)


func test_input_direction_not_smashing_stick_from_resting_causes_walking_state() -> void:
	player.state = Player.State.RESTING
	player.input_direction = 1
	player.smashing_stick = false
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.WALKING)


func test_input_direction_while_dashing_within_dash_timer_causes_dashing_state() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.input_direction = 1
	player.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASHING)


func test_input_direction_while_dashing_above_dash_timer_causes_running_state() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES + 1
	player.input_direction = 1
	player.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.RUNNING)


func test_releasing_input_direction_while_dashing_causes_dash_release_state() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.input_direction = 0
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASH_RELEASE)


func test_reverse_input_direction_while_dashing_causes_pivot() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 1
	player.input_direction = -1
	player.smashing_stick = true
	player._apply_inputs_depending_on_state()
	var pivot_velocity: float = player.velocity.x

	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 0
	player.input_direction = 1
	player.smashing_stick = true
	player._apply_inputs_depending_on_state()
	var non_pivot_velocity: float = player.velocity.x
	
	# Pivot resets velocity to 0, so there should be no effect from the initial velocity opposing it
	assert_true(sign(pivot_velocity) == -1)
	assert_true(sign(non_pivot_velocity) == 1)
	assert_true(abs(pivot_velocity) == abs(non_pivot_velocity))


func test_reverse_input_direction_while_dashing_resets_dashing_frame_count() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 1
	player.input_direction = -1
	player.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_true(player.dashing_frame_count == 1)


func test_reverse_input_direction_not_smashing_stick_while_dashing_causes_dash_release() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 1
	player.input_direction = -1
	player.smashing_stick = false
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.DASH_RELEASE)


func test_reverse_input_direction_not_smashing_stick_while_dash_releasing_causes_no_state_change() -> void:
	player.state = Player.State.DASH_RELEASE
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 1
	player.input_direction = -1
	player.smashing_stick = false
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.DASH_RELEASE)


func test_reapplying_forward_input_direction_during_dash_release_causes_no_velocity_increase() -> void:
	player.state = Player.State.DASH_RELEASE
	player.velocity.x = 1
	player.input_direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x < 1)	# slowed due to friction


func test_grounded_with_non_zero_velocity_within_dash_timer_causes_dashing_animation() -> void:
	player.on_floor = true
	player.velocity = Vector2(100, 0)
	player.dashing_frame_count = player.DASHING_FRAMES
	player._check_for_physics_transitions()
	
	# use "resting" animation for dashing
	assert_eq(player.get_node("AnimatedSprite2D").animation, "resting")


func test_x_velocity_with_no_input_leads_to_slowing_by_friction() -> void:
	player.velocity.x = 100
	player.state = Player.State.RUNNING
	player.input_direction = 0
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x < 100)


func test_y_velocity_with_no_input_leads_to_slowing_by_gravity() -> void:
	player.velocity.y = -100
	player.on_floor = false
	player.state = Player.State.JUMPING
	player.gravity_vector = Vector2(0, player.GRAVITY)
	player._apply_gravity(1)
	
	assert_true(player.velocity.y > -100)


func test_smash_stick_input_is_read_correctly() -> void:
	player.input_axis = player.SMASH_STICK_AXIS + 0.1
	player.smash_stick_right_frame_count = player.SMASH_STICK_FRAMES
	player._check_for_smash_stick()
	
	assert_true(player.smashing_stick)


func test_left_inputs_reset_smash_stick_right_frame_count() -> void:
	player.input_direction = -1.0
	player.smash_stick_right_frame_count = 1
	player._check_for_smash_stick()
	assert_true(player.smash_stick_right_frame_count == 0)


func test_right_inputs_reset_smash_stick_left_frame_count() -> void:
	player.input_direction = 1.0
	player.smash_stick_left_frame_count = 1
	player._check_for_smash_stick()
	assert_true(player.smash_stick_left_frame_count == 0)


func test_smash_stick_input_persists_while_input_is_held() -> void:
	player.input_axis = 1.0
	player.smash_stick_right_frame_count = player.SMASH_STICK_FRAMES + 1
	player.smashing_stick = true
	player._check_for_smash_stick()
	
	assert_true(player.smashing_stick)


func test_smash_stick_release_resets_boolean_tracker() -> void:
	player.input_axis = 0.5
	player.smash_stick_right_frame_count = player.SMASH_STICK_FRAMES + 1
	player.smashing_stick = true
	player._check_for_smash_stick()
	
	assert_false(player.smashing_stick)


func test_smashing_stick_stops_increments_smash_stick_frame_count() -> void:
	player.input_axis = 1.0
	player.smash_stick_right_frame_count = 100
	player._check_for_smash_stick()
	
	assert_true(player.smash_stick_right_frame_count == 100)
