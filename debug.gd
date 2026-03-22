extends Label

@onready var player: CharacterBody2D = $"../../Player"
var max_input_axis: float = -1.0
var state: String
var recent_states: Array[String] = ["-", "-", "-", "-", "-"]

func _process(_delta: float) -> void:
	if player.inputs.axis > max_input_axis:
		max_input_axis = player.inputs.axis
		
	state = Player.State.keys()[player.state]
	_update_recent_states(state)
	
	text = "state: %s
	recent_states: [ %s, %s, %s, %s, %s ]
	dashing_frame_count: %s
	smashing_stick: %s
	smash_stick_left_frame_count: %s
	smash_stick_right_frame_count: %s
	input_direction: %s
	input_axis: %s
	max_input_direction: %s
	speed: %s" % [
		state,
		recent_states[0], recent_states[1], recent_states[2], recent_states[3], recent_states[4],
		player.dashing_frame_count,
		player.inputs.smashing_stick,
		player.inputs.smash_stick_left_frame_count,
		player.inputs.smash_stick_right_frame_count,
		player.inputs.axis,
		player.inputs.direction,
		max_input_axis,
		player.velocity.x
	]

func _update_recent_states(new_state: String) -> void:
	var end_index: int = recent_states.find(new_state)
	if end_index == -1:
		end_index = recent_states.size() - 1

	for i in range(end_index, 0, -1):
		recent_states[i] = recent_states[i - 1]
	recent_states[0] = new_state
