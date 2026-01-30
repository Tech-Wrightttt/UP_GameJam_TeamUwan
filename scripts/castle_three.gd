extends Node2D


# Called when the node enters the scene tree for the first time.
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite1: AnimatedSprite2D = $AnimatedSprite2D2
func _ready() -> void:
	$main_character.global_position = GameManager.spawn_points[3]
	sprite.play("default")
	sprite1.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_towardso_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		GameManager.fade_out(get_tree().current_scene,"res://levels/castle_two.tscn", 0.8,Color.BLACK)




func _on_towardsc_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		GameManager.fade_out(get_tree().current_scene,"res://levels/castle_bossroom.tscn",0.8,Color.BLACK)


var player

func _on_marker_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		player = body  # Store the Node2D itself, not body.name
		if player and is_instance_valid(player):
			GameManager.spawn_points[3] = player.global_position
			
			
			
@onready var sound_player: AudioStreamPlayer2D = $"voice area/AudioStreamPlayer2D"

func _on_voice_area_body_entered(body: Node2D) -> void:
	if body.name != "main_character" or GameManager.castle3_voiceline_played:
		return
	
	GameManager.castle3_voiceline_played = true
	sound_player.play()
