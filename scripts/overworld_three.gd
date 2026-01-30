extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if UI:
		UI.show_hud()
		
	$main_character.global_position = GameManager.spawn_points[7]
	

func _on_towardso_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		GameManager.fade_out(get_tree().current_scene,"res://levels/overworld_two.tscn", 0.8,Color.BLACK)




func _on_towardsc_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		GameManager.fade_out(get_tree().current_scene,"res://levels/overworld_bossroom.tscn",0.8,Color.BLACK)


var player

func _on_marker_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		player = body  # Store the Node2D itself, not body.name
		if player and is_instance_valid(player):
			GameManager.spawn_points[7] = player.global_position
