extends GutTest

var player: Player

func before_each() -> void:
	player = Player.new()
	
func after_each() -> void:
	player.free()
	

func test_airborne_with_upwards_velocity_causes_jumping_state() -> void:
	player.on_floor = false
	player.velocity = Vector2(0, -100)
	player._update_state()
	
	assert_eq(player.state, Player.State.JUMPING)
	

func test_airborne_with_downwards_velocity_causes_falling_state() -> void:
	player.on_floor = false
	player.velocity = Vector2(0, 100)
	player._update_state()
	
	assert_eq(player.state, Player.State.FALLING)


func test_grounded_with_no_velocity_causes_resting_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(0, 0)
	player._update_state()
	
	assert_eq(player.state, Player.State.RESTING)


func test_grounded_with_non_zero_velocity_causes_walking_or_dashing_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(100, 0)
	player._update_state()
	
	assert_true(player.state in [Player.State.WALKING, Player.State.DASHING])


func test_grounded_with_non_zero_velocity_within_dash_timer_causes_dashing_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(100, 0)
	player.dashing_frame_count = 1
	player._update_state()
	
	assert_eq(player.state, Player.State.DASHING)


func test_jump_from_resting_decreases_y_velocity() -> void:
	player.state = Player.State.RESTING
	player._jump()
	
	assert_true(player.velocity.y < 0)
	

func test_input_direction_from_resting_increases_x_velocity() -> void:
	player.state = Player.State.RESTING
	player.input_direction = 1
	player._apply_on_ground_physics()
	
	assert_true(player.velocity.x > 0)


func test_x_velocity_with_no_input_leads_to_slowing_by_friction() -> void:
	player.velocity.x = 100
	player.state = Player.State.RESTING
	player.input_direction = 0
	player._apply_on_ground_physics()
	
	assert_true(player.velocity.x < 100)


func test_y_velocity_with_no_input_leads_to_slowing_by_gravity() -> void:
	player.velocity.y = -100
	player.on_floor = false
	player.state = Player.State.JUMPING
	player.gravity_vector = Vector2(0, player.GRAVITY)
	player._apply_gravity()
	
	assert_true(player.velocity.y > -100)
