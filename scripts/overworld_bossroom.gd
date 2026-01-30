extends Node2D

@onready var door1: AnimatedSprite2D = $door
@onready var interact_label: Label = $InteractLabel

# state variables
var boss_defeated: bool = false
var player_near_door: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($main_character.global_position)
	$main_character.global_position = GameManager.spawn_points[0]
	
	interact_label.visible = false

	# TEST: simulate boss defeat after 2 seconds using await
	await get_tree().create_timer(2.0).timeout
	boss_defeated_triggered()
	print("Boss defeated for testing")

func _process(delta: float) -> void:
	if boss_defeated:
		door1.visible = true

		# show label if player is near
		interact_label.visible = player_near_door

		if player_near_door and Input.is_action_just_pressed("interact"):
			# go to ending (commented out)
			# get_tree().change_scene("res://scenes/Ending.tscn")
			print("Player interacts with the door — ending triggered")
			

# call this when boss is defeated
func boss_defeated_triggered() -> void:
	boss_defeated = true

# track player near door (connect Area2D signals)
func _on_Door_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		player_near_door = true

func _on_Door_area_exited(area: Area2D) -> void:
	if area.name == "Player":
		player_near_door = false


func _on_door_area_body_entered(body: Node2D) -> void:
	# check if the player entered
	if body == player:
		player_near_door = true
		interact_label.visible = true  # show [E] to interact

func _on_door_area_body_exited(body: Node2D) -> void:
	# check if the player exited
	if body == player:
		player_near_door = false
		interact_label.visible = false  # hide [E] to interact



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
