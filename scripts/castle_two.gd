extends Node2D

const TOTAL_CLOCKS := 3

@onready var counter_label: Label = $counter

func _ready():
	$main_character.global_position = GameManager.spawn_points[2]
	#update_counter()
	print("Level Started")

func add_clock():
	GameManager.add_clock()  # Global counter
	#update_counter()

#func update_counter():
	#counter_label.text = str(GameManager.current_clocks) + "/" + str(TOTAL_CLOCKS)


func _on_towardso_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		GameManager.fade_out(get_tree().current_scene,"res://levels/castle_one.tscn", 0.8,Color.BLACK)




func _on_towardsc_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		GameManager.fade_out(get_tree().current_scene,"res://levels/castle_three.tscn",0.8,Color.BLACK)


var player

func _on_marker_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		player = body  # Store the Node2D itself, not body.name
		if player and is_instance_valid(player):
			GameManager.spawn_points[2] = player.global_position



func _on_towards_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
