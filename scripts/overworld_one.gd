extends Node2D

@onready var npc: AnimatedSprite2D = $npc
@onready var interact_label: Label = $InteractLabel
var player_near_npc: bool = false
@onready var player: CharacterBody2D = $main_character

@onready var layer1 = $CanvasLayer2
@onready var layer2 = $CanvasLayer3

@onready var anim_player1 = $CanvasLayer2/AnimationPlayer
@onready var anim_player2 = $CanvasLayer3/AnimationPlayer

var dialogue_active: bool = false  # Track if dialogue is currently playing
var can_interact: bool = true     # Allow interaction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.transition_music("overworld")
	$main_character.global_position = GameManager.spawn_points[5]
	if npc.has_method("play"):
		npc.play("default")
	
	interact_label.visible = false
	layer1.hide()
	layer2.hide()
	
	find_player()

func _process(delta: float) -> void:
	if player_near_npc and Input.is_action_just_pressed("interact") and not dialogue_active and can_interact:
		interact_with_npc()

func find_player():
	# Try to find the player in the scene
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("Found player: ", player.name)
	else:
		print("Player not found. Make sure player is in 'player' group.")

func interact_with_npc():
	print("Starting NPC dialogue")
	dialogue_active = true
	can_interact = false  # Prevent further interactions during dialogue
	interact_label.visible = false
	
	# Disable player movement
	if player and player.has_method("set_physics_process"):
		player.set_physics_process(false)
	
	await start_dialogue()
	
	# Re-enable player movement
	if player and player.has_method("set_physics_process"):
		player.set_physics_process(true)
	
	dialogue_active = false
	
	# Add a cooldown before allowing interaction again
	await get_tree().create_timer(0.5).timeout
	can_interact = true
	
	print("Dialogue finished - can interact again")

func start_dialogue():
	print("NPC says: Hello, adventurer!")
	
	layer1.show()
	anim_player1.play("typewriter")
	await get_tree().create_timer(7.0).timeout
	layer1.hide()
	await get_tree().create_timer(0.5).timeout
	
	layer2.show()
	anim_player2.play("typewriter")
	await get_tree().create_timer(9.0).timeout
	layer2.hide()

func _on_npcarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_interact and not dialogue_active:
		player_near_npc = true
		player = body
		interact_label.visible = true
		print("Player near NPC - Press E to talk")

func _on_npcarea_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near_npc = false
		interact_label.visible = false
		print("Player left NPC")


func _on_towardtut_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		AudioManager.stop_music()
		GameManager.fade_out(get_tree().current_scene,"res://levels/tutoriallevel.tscn",0.8,Color.BLACK)


func _on_towardto_2_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		AudioManager.stop_music()
		GameManager.fade_out(get_tree().current_scene,"res://levels/overworld_two.tscn",0.8,Color.BLACK)


func _on_marker_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		player = body  # Store the Node2D itself, not body.name
		if player and is_instance_valid(player):
			GameManager.spawn_points[5] = player.global_position
