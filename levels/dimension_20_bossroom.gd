extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.transition_music("bossfight")
	$main_character.DASH_SPEED = 1500


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
