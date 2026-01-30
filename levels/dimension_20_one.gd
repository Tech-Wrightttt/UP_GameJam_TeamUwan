extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.transition_music("darkworld")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_towardso_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		AudioManager.stop_music()
		GameManager.fade_out(get_tree().current_scene,"res://levels/dimension20_two.tscn", 0.8,Color.BLACK)
