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


func test_airborne_with_upwards_velocity_causes_jumping_state() -> void:
	player.on_floor = false
	player.velocity = Vector2(0, -100)
	player._update_state_depending_on_physics()
	
	assert_eq(player.state, Player.State.JUMPING)
	

func test_airborne_with_downwards_velocity_causes_falling_state() -> void:
	player.on_floor = false
	player.velocity = Vector2(0, 100)
	player._update_state_depending_on_physics()
	
	assert_eq(player.state, Player.State.FALLING)


func test_falling_with_crouch_input_leads_to_fast_falling_state() -> void:
	player.on_floor = false
	player.velocity = Vector2(0, 100)
	player.state = Player.State.FALLING
	player.crouch_inputted = true
	player._update_state_depending_on_physics()
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.FAST_FALLING)


func test_airborne_causes_jumping_animation() -> void:
	player.on_floor = false
	player._update_state_depending_on_physics()
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.get_node("AnimatedSprite2D").animation, "jumping")


func test_grounded_with_no_velocity_causes_resting_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(0, 0)
	player._update_state_depending_on_physics()
	
	assert_eq(player.state, Player.State.RESTING)


func test_grounded_with_no_velocity_or_input_causes_resting_animation() -> void:
	player.on_floor = true
	player.velocity = Vector2(0, 0)
	player._update_state_depending_on_physics()
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


func test_jump_input_from_walking_decreases_y_velocity() -> void:
	player.jump_inputted = true
	player.state = Player.State.WALKING
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.y < 0)
	

func test_input_direction_from_resting_increases_x_velocity() -> void:
	player.state = Player.State.RESTING
	player.input_direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_true(player.velocity.x > 0)


func test_input_direction_from_resting_causes_dashing_state() -> void:
	player.state = Player.State.RESTING
	player.input_direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASHING)
	

func test_input_direction_while_dashing_within_dash_timer_causes_dashing_state() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES - 1
	player.input_direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASHING)


func test_input_direction_while_dashing_above_dash_timer_causes_walking_state() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES + 1
	player.input_direction = 1
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.WALKING)


func test_releasing_input_direction_while_dashing_causes_dash_release_state() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES - 1
	player.input_direction = 0
	player._apply_inputs_depending_on_state()
	
	assert_eq(player.state, Player.State.DASH_RELEASE)


func test_reverse_input_direction_while_dashing_causes_pivot() -> void:
	player.state = Player.State.DASHING
	player.dashing_frame_count = player.DASHING_FRAMES - 1
	player.velocity.x = 1
	player.input_direction = -1
	player._apply_inputs_depending_on_state()
	
	# Pivot resets velocity to 0, so the next physics update will not have to decelerate
	assert_true(player.velocity.x == 0)


func test_grounded_with_non_zero_velocity_within_dash_timer_causes_dashing_animation() -> void:
	player.on_floor = true
	player.velocity = Vector2(100, 0)
	player.dashing_frame_count = player.DASHING_FRAMES - 1
	player._update_state_depending_on_physics()
	
	# use "resting" animation for dashing
	assert_eq(player.get_node("AnimatedSprite2D").animation, "resting")


func test_x_velocity_with_no_input_leads_to_slowing_by_friction() -> void:
	player.velocity.x = 100
	player.state = Player.State.WALKING
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
