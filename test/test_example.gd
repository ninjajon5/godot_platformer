extends GutTest

func test_jump_from_idle_updates_state_and_decreases_y_velocity() -> void:
	var player = Player.new()
	player.state = Player.State.RESTING
	player._jump()
	
	assert_eq(player.state, Player.State.JUMPING)
	assert_true(player.velocity.y < 0)
