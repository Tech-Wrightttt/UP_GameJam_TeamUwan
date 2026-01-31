extends Node2D

@onready var npc: AnimatedSprite2D = $npc
@onready var interact_label: Label = $InteractLabel

var player_near_npc: bool = false
var player_near_portal: bool = false  # Track if player is near portal

@onready var player: CharacterBody2D = $main_character

@onready var layer1 = $CanvasLayer2
@onready var layer2 = $CanvasLayer3
@onready var layer3 = $CanvasLayer4  # For "all shards collected" dialogue

@onready var anim_player1 = $CanvasLayer2/AnimationPlayer
@onready var anim_player2 = $CanvasLayer3/AnimationPlayer
@onready var anim_player3 = $CanvasLayer4/AnimationPlayer

@onready var portal: Area2D = $LevelPortal

var dialogue_active: bool = false
var can_interact: bool = true
var portal_unlocked: bool = false  # Track if portal has been unlocked through dialogue


func _ready() -> void:
	AudioManager.transition_music("overworld")
	$main_character.global_position = GameManager.spawn_points[5]

	if npc.has_method("play"):
		npc.play("default")

	interact_label.visible = false
	layer1.hide()
	layer2.hide()
	layer3.hide()

	# Hide portal initially
	if portal:
		portal.visible = false
		portal.monitoring = false
		print("Portal found and hidden")

	find_player()


func _process(delta: float) -> void:
	# Debug info
	if Input.is_action_just_pressed("ui_accept"):
		print(
			"DEBUG - Near NPC: ", player_near_npc,
			" | Near Portal: ", player_near_portal,
			" | Portal Unlocked: ", portal_unlocked
		)
		print("DEBUG - Shards: ", GameManager.current_clocks, "/", GameManager.TOTAL_CLOCKS)

	# Handle NPC interaction
	if player_near_npc and Input.is_action_just_pressed("interact") and not dialogue_active and can_interact:
		print("Interacting with NPC")
		interact_with_npc()

	# Handle portal interaction
	if player_near_portal and Input.is_action_just_pressed("interact") and portal_unlocked:
		print("Interacting with portal")
		enter_portal()


func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("Found player: ", player.name)
	else:
		print("Player not found. Make sure player is in 'player' group.")


# Show and activate the portal
func show_portal() -> void:
	if portal:
		portal.visible = true
		portal.monitoring = true
		portal.monitorable = true
		print("✓ Portal is now visible and monitoring!")
		print("✓ Portal position: ", portal.global_position)
	else:
		print("ERROR: Cannot show portal - portal reference is null!")


# Enter the portal
func enter_portal() -> void:
	print("=== ENTERING DARK DIMENSION ===")
	AudioManager.stop_music()
	GameManager.fade_out(
		get_tree().current_scene,
		"res://levels/dimension20_one.tscn",
		1.5,
		Color.BLACK
	)


func interact_with_npc() -> void:
	print("Starting NPC dialogue")
	dialogue_active = true
	can_interact = false
	interact_label.visible = false

	# Disable player movement
	if player and player.has_method("set_physics_process"):
		player.set_physics_process(false)

	await start_dialogue()

	# Re-enable player movement
	if player and player.has_method("set_physics_process"):
		player.set_physics_process(true)

	dialogue_active = false
	await get_tree().create_timer(0.5).timeout
	can_interact = true

	print("Dialogue finished - can interact again")


func start_dialogue() -> void:
	# Check if player has all shards and hasn't unlocked portal yet
	if GameManager.current_clocks >= GameManager.TOTAL_CLOCKS and not portal_unlocked:
		print("=== ALL SHARDS COLLECTED - SPECIAL DIALOGUE ===")

		layer3.show()
		anim_player3.play("typewriter")
		await get_tree().create_timer(8.0).timeout
		layer3.hide()

		portal_unlocked = true
		print("Portal unlocked! Spawning portal...")
		show_portal()
	else:
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
	print("NPC area entered by: ", body.name)
	if body.is_in_group("player") and can_interact and not dialogue_active:
		player_near_npc = true
		player = body
		interact_label.visible = true
		interact_label.text = "Press E to talk"
		print("✓ Player near NPC - Press E to talk")


func _on_npcarea_body_exited(body: Node2D) -> void:
	print("NPC area exited by: ", body.name)
	if body.is_in_group("player"):
		player_near_npc = false
		if not player_near_portal:
			interact_label.visible = false
		print("Player left NPC")


func _on_towardtut_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		AudioManager.stop_music()
		GameManager.fade_out(
			get_tree().current_scene,
			"res://levels/tutoriallevel.tscn",
			0.8,
			Color.BLACK
		)


func _on_towardto_2_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		AudioManager.stop_music()
		GameManager.fade_out(
			get_tree().current_scene,
			"res://levels/overworld_two.tscn",
			0.8,
			Color.BLACK
		)


func _on_marker_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		player = body
		if player and is_instance_valid(player):
			GameManager.spawn_points[5] = player.global_position


@onready var sound_player: AudioStreamPlayer2D = $"voice area/AudioStreamPlayer2D"

func _on_voice_area_body_entered(body: Node2D) -> void:
	print("on voice area body entered")
	print("playing:", sound_player.playing)

	if body.name != "main_character" or GameManager.overworld1_voiceline_played:
		return

	print("on voice area body entered reached")
	GameManager.overworld1_voiceline_played = true
	AudioManager.stop_music()

	sound_player.play()

	print("playing:", sound_player.playing)
	print(sound_player)
