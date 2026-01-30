extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite1: AnimatedSprite2D = $AnimatedSprite2D2
@onready var sprite2: AnimatedSprite2D = $AnimatedSprite2D3
@onready var sprite3: AnimatedSprite2D = $AnimatedSprite2D4
@onready var sprite4: AnimatedSprite2D = $AnimatedSprite2D5
@onready var player: CharacterBody2D = $main_character
@onready var door1: TileMap = $door
@onready var interact_label: Label = $InteractLabel

# state variables
var boss_defeated: bool = false
var player_near_door: bool = false

func _ready() -> void:
	sprite.play("default")
	sprite1.play("default")
	sprite2.play("default")
	sprite3.play("default")
	sprite4.play("default")

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
			#get_tree().change_scene("res://storylines/died_demonking.tscn")
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
