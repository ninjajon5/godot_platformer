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


func test_grounded_after_falling_with_no_velocity_causes_walking_state() -> void:
	player.on_floor = true
	player.velocity = Vector2(5, 0)
	player.state = Player.State.FAST_FALLING
	player._check_for_physics_transitions()
	
	assert_eq(player.state, Player.State.WALKING)


func test_grounded_with_no_velocity_or_input_causes_resting_animation() -> void:
	player.on_floor = true
	player.velocity = Vector2(0, 0)
	player._check_for_physics_transitions()
	player._apply_inputs_depending_on_state()
	assert_eq(player.get_node("AnimatedSprite2D").animation, "resting")
