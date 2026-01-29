extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($main_character.global_position)
	$main_character.global_position = GameManager.spawn_points[0]
	







func _on_towardso_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		GameManager.fade_out(get_tree().current_scene,"res://levels/overworld_one.tscn", 0.8,Color.BLACK)




func _on_towardsc_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		GameManager.fade_out(get_tree().current_scene,"res://levels/castle_one.tscn",0.8,Color.BLACK)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_npcarea_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

var player

func _on_marker_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		player = body  # Store the Node2D itself, not body.name
		if player and is_instance_valid(player):
			GameManager.spawn_points[0] = player.global_position
			print("OTEN")
			print(GameManager.tutorialLocation)
