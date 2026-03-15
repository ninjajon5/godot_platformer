extends GutTest

const DELTA: float = 1.0 / 60.0

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


func test_grounded_with_non_zero_velocity_causes_walking_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(100, 0)
	player._update_state()
	
	assert_eq(player.state, Player.State.WALKING)


func test_jump_from_resting_decreases_y_velocity() -> void:
	player.state = Player.State.RESTING
	player._jump()
	
	assert_true(player.velocity.y < 0)
	

func test_walk_from_resting_increases_x_velocity() -> void:
	player.state = Player.State.RESTING
	player.input_direction = 1
	player._apply_on_ground_physics()
	player._update_state()
	
	assert_true(player.velocity.x > 0)
	
