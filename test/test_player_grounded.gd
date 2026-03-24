extends GutTest

var player: Player

func before_each() -> void:
	#player = autoqfree(load("res://player.tscn").instantiate())
	player = load("res://player.tscn").instantiate()
	add_child(player)
	player.state = Player.State.RESTING
	

func after_each() -> void:
	player.queue_free()
	

# =================================
# Tests should often be:
# 1. Define state
# 2. Define inputs
# 3. Run function to evaluate both
# 4. Assert on the result
# =================================

func test_direction_from_resting_increases_x_velocity() -> void:
	player.state = Player.State.RESTING
	player.inputs.axis = 1
	player.inputs.direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x > 0)


func test_direction_smashing_stick_from_resting_causes_dashing_state() -> void:
	player.state = Player.State.RESTING
	player.inputs.direction = 1
	player.inputs.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASHING)


func test_direction_not_smashing_stick_from_resting_causes_walking_state() -> void:
	player.state = Player.State.RESTING
	player.inputs.direction = 1
	player.inputs.smashing_stick = false
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.WALKING)


func test_max_axis_not_smashing_stick_while_walking_causes_walking_speed() -> void:
	player.state = Player.State.WALKING
	player.velocity.x = player.WALKING_SPEED - (0.5 * player.ACCELERATION)
	player.inputs.direction = 1
	player.inputs.axis = 1.0
	player.inputs.smashing_stick = false
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x == Player.WALKING_SPEED)


func test_direction_smashing_stick_from_walking_causes_dashing_state() -> void:
	player.state = Player.State.WALKING
	player.inputs.direction = 1
	player.inputs.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASHING)


func test_axis_while_walking_causes_velocity_change() -> void:
	player.state = Player.State.WALKING
	player.inputs.direction = 1
	player.inputs.smashing_stick = false
	player.inputs.axis = 0.4
	player.velocity.x = Player.RUNNING_SPEED
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x < Player.RUNNING_SPEED)


func test_direction_while_dashing_within_dash_timer_causes_dashing_state() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.inputs.direction = 1
	player.inputs.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASHING)


func test_direction_while_dashing_above_dash_timer_causes_running_state() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES + 1
	player.inputs.direction = 1
	player.inputs.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.RUNNING)


func test_releasing_direction_while_dashing_causes_dash_release_state() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.inputs.direction = 0
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASH_RELEASE)


func test_reverse_direction_while_dashing_causes_pivot() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 1
	player.inputs.direction = -1
	player.inputs.smashing_stick = true
	player._apply_inputs_depending_on_state()
	var pivot_velocity: float = player.velocity.x

	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 0
	player.inputs.direction = 1
	player.inputs.smashing_stick = true
	player._apply_inputs_depending_on_state()
	var non_pivot_velocity: float = player.velocity.x
	
	# Pivot resets velocity to 0, so there should be no effect from the initial velocity opposing it
	assert_true(sign(pivot_velocity) == -1)
	assert_true(sign(non_pivot_velocity) == 1)
	assert_true(abs(pivot_velocity) == abs(non_pivot_velocity))


func test_reverse_direction_while_dashing_resets_dashing_frame_count() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 1
	player.inputs.direction = -1
	player.inputs.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_true(player.dashing_frame_count == 1)


func test_reverse_direction_not_smashing_stick_while_dashing_causes_dash_release() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 1
	player.inputs.direction = -1
	player.inputs.smashing_stick = false
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.DASH_RELEASE)


func test_reverse_direction_not_smashing_stick_while_dash_releasing_causes_no_state_change() -> void:
	player.state = Player.State.DASH_RELEASE
	player.dashing_frame_count = player.DASHING_FRAMES
	player.velocity.x = 1
	player.inputs.direction = -1
	player.inputs.smashing_stick = false
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.DASH_RELEASE)


func test_reverse_direction_while_running_causes_run_turnaround() -> void:
	player.state = Player.State.RUNNING
	player.velocity.x = player.RUNNING_SPEED
	player.inputs.axis = -1.0
	player.inputs.direction = -1
	player._apply_inputs_depending_on_state()
	
	assert_true(player.state == Player.State.RUN_TURNAROUND)


func test_run_turnaround_flips_animation() -> void:
	player.state = Player.State.RUNNING
	player.velocity.x = Player.RUNNING_SPEED
	player.inputs.direction = -1
	player._apply_inputs_depending_on_state()
	
	assert_true(player.get_node("AnimatedSprite2D").flip_h == true)
	
	player.state = Player.State.RUNNING
	player.velocity.x = -Player.RUNNING_SPEED
	player.inputs.direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_true(player.get_node("AnimatedSprite2D").flip_h == false)


func test_smashing_stick_into_run_turnaround_resets_smashing_stick() -> void:
	player.state = Player.State.RUNNING
	player.velocity.x = player.RUNNING_SPEED
	player.inputs.axis = -1.0
	player.inputs.direction = -1
	player.inputs.smashing_stick = true
	player._apply_inputs_depending_on_state()
	
	assert_false(player.inputs.smashing_stick)


func test_run_turnaround_prevents_smashing_stick() -> void:
	player.state = Player.State.RUN_TURNAROUND
	player.inputs.smashing_stick = true
	player.inputs.direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_false(player.inputs.smashing_stick)
	assert_true(player.inputs.smash_stick_right_frame_count > player.inputs.SMASH_STICK_FRAMES)


func test_reapplying_forward_direction_during_dash_release_causes_no_velocity_increase() -> void:
	player.state = Player.State.DASH_RELEASE
	player.velocity.x = 1
	player.inputs.direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x < 1)	# slowed due to friction


func test_x_velocity_with_no_input_leads_to_slowing_by_friction() -> void:
	player.velocity.x = 100
	player.state = Player.State.RUNNING
	player.inputs.direction = 0
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x < 100)


func test_smash_stick_input_is_read_correctly() -> void:
	player.inputs.axis = player.inputs.SMASH_STICK_AXIS + 0.1
	player.inputs.smash_stick_right_frame_count = player.inputs.SMASH_STICK_FRAMES
	player.inputs._check_for_smash_stick()
	
	assert_true(player.inputs.smashing_stick)


func test_left_inputs_reset_smash_stick_right_frame_count() -> void:
	player.inputs.direction = -1.0
	player.inputs.smash_stick_right_frame_count = 1
	player.inputs._check_for_smash_stick()
	assert_true(player.inputs.smash_stick_right_frame_count == 0)


func test_right_inputs_reset_smash_stick_left_frame_count() -> void:
	player.inputs.direction = 1.0
	player.inputs.smash_stick_left_frame_count = 1
	player.inputs._check_for_smash_stick()
	assert_true(player.inputs.smash_stick_left_frame_count == 0)


func test_smash_stick_input_persists_while_input_is_held() -> void:
	player.inputs.axis = 1.0
	player.inputs.smash_stick_right_frame_count = player.inputs.SMASH_STICK_FRAMES + 1
	player.inputs.smashing_stick = true
	player.inputs._check_for_smash_stick()
	
	assert_true(player.inputs.smashing_stick)


func test_smash_stick_release_resets_boolean_tracker() -> void:
	player.inputs.axis = 0.5
	player.inputs.smash_stick_right_frame_count = player.inputs.SMASH_STICK_FRAMES + 1
	player.inputs.smashing_stick = true
	player.inputs._check_for_smash_stick()
	
	assert_false(player.inputs.smashing_stick)


func test_smashing_stick_stops_incrementing_smash_stick_frame_count() -> void:
	player.inputs.axis = 1.0
	player.inputs.smash_stick_right_frame_count = 100
	player.inputs._check_for_smash_stick()
	
	assert_true(player.inputs.smash_stick_right_frame_count == 100)
