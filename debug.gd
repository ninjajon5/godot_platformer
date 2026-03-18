extends Label

@onready var player: CharacterBody2D = $"../../Player"

func _process(_delta: float) -> void:
	text = "State: %s" % Player.State.keys()[player.state]
