extends GutTest

const DELTA: float = 1.0 / 60.0


func test_jump_from_resting_decreases_y_velocity() -> void:
	var player: Player = Player.new()
	player.state = Player.State.RESTING
	player._jump()
	
	assert_true(player.velocity.y < 0)


func test_airborne_with_upwards_velocity_causes_jumping_state() -> void:
	var player: Player = Player.new()
	player.on_floor = false
	player.velocity = Vector2(0, -100)
	player._update_state()
	
	assert_eq(player.state, Player.State.JUMPING)
