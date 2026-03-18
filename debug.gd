extends Label

@onready var player: CharacterBody2D = $"../../Player"

func _process(_delta: float) -> void:
	text = "state: %s\ndashing_frame_count: %s" % [
		Player.State.keys()[player.state],
		player.dashing_frame_count
	]
