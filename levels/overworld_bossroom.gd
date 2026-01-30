extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


@onready var sound_player: AudioStreamPlayer2D = $"voice area/AudioStreamPlayer2D"


func _on_voice_area_body_entered(body: Node2D) -> void:
	if body.name != "main_character" or GameManager.overworld4_voiceline_played:
		return
	
	GameManager.overworld4_voiceline_played = true
	sound_player.play()
