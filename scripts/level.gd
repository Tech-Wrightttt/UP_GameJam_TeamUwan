extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if UI:
		UI.show_hud()
	
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


func _on_neutral_ending_body_entered(body):
	if body.name == "main_character":
		GameManager.reset_spawn_points()
		GameManager.fade_out(
			self,
			"res://storylines/neutral_ending.tscn",
			1.5,
			Color.BLACK
		)
		

@onready var sound_player: AudioStreamPlayer2D = $"voice area/AudioStreamPlayer2D"
@onready var sound_player2: AudioStreamPlayer2D = $"voice area/AudioStreamPlayer2D2"
@onready var sound_player3: AudioStreamPlayer2D = $"voice area/AudioStreamPlayer2D3"
@onready var sound_player4: AudioStreamPlayer2D = $"voice area/AudioStreamPlayer2D4"

func _on_voice_area_body_entered(body: Node2D) -> void:
	if body.name != "main_character" or GameManager.voice_line_played:
		return
	
	GameManager.voice_line_played = true
	sound_player.play()
	await get_tree().create_timer(3.0).timeout
	sound_player2.play()
	await get_tree().create_timer(3.0).timeout
	sound_player3.play()
	await get_tree().create_timer(2.0).timeout
	sound_player4.play()
	
	
@onready var twosound_player: AudioStreamPlayer2D = $"voice area2/AudioStreamPlayer2D"
@onready var twosound_player2: AudioStreamPlayer2D = $"voice area2/AudioStreamPlayer2D2"


func _on_voice_area_body_entered2(body: Node2D) -> void:
	if body.name != "main_character" or GameManager.voice_line_played2:
		return
	
	GameManager.voice_line_played2 = true
	twosound_player.play()
	await get_tree().create_timer(4.0).timeout
	twosound_player2.play()
	
	
@onready var threesound_player: AudioStreamPlayer2D = $"voice area3/AudioStreamPlayer2D"
func _on_voice_area_body_entered3(body: Node2D) -> void:
	if body.name != "main_character" or GameManager.voice_line_played3:
		return
	
	GameManager.voice_line_played3 = true
	threesound_player.play()

		

@onready var foursound_player: AudioStreamPlayer2D = $"voice area4/AudioStreamPlayer2D"
func _on_voice_area_body_entered4(body: Node2D) -> void:
	if body.name != "main_character" or GameManager.voice_line_played4:
		return
	
	GameManager.voice_line_played4 = true
	foursound_player.play()
