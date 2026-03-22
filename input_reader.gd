class_name InputReader
extends RefCounted

const SMASH_STICK_FRAMES: int = 4
const SMASH_STICK_AXIS: float = 0.75

var jump: bool = false
var crouch: bool = false
var left: bool = false
var right: bool = false
var axis: float = 0.0
var direction: float = 0
var smash_stick_left_frame_count: int = 0
var smash_stick_right_frame_count: int = 0
var smashing_stick: bool = false

func read_inputs() -> void:
	jump = Input.is_action_just_pressed("jump")
	crouch = Input.is_action_just_pressed("crouch")
	left = Input.is_action_just_pressed("left")
	right = Input.is_action_just_pressed("right")
	axis = Input.get_axis("left", "right")
	direction = sign(axis)
	_check_for_smash_stick()
	

func reset_smashing_stick() -> void:
	smashing_stick = false
	if direction == -1:
		smash_stick_left_frame_count = SMASH_STICK_FRAMES + 1
	elif direction == 1:
		smash_stick_right_frame_count = SMASH_STICK_FRAMES + 1


func _check_for_smash_stick() -> void:	
	if axis >= SMASH_STICK_AXIS:
		if smash_stick_right_frame_count <= SMASH_STICK_FRAMES:
			smashing_stick = true
	elif axis <= -SMASH_STICK_AXIS:
		if smash_stick_left_frame_count <= SMASH_STICK_FRAMES:
			smashing_stick = true
	else:
		smashing_stick = false
		_update_smash_stick_frame_counts()


func _update_smash_stick_frame_counts() -> void:
	if direction > 0.0:
		smash_stick_left_frame_count = 0
		smash_stick_right_frame_count += 1
	elif direction < 0.0:
		smash_stick_left_frame_count += 1
		smash_stick_right_frame_count = 0
	else:
		smash_stick_left_frame_count = 0
		smash_stick_right_frame_count = 0
