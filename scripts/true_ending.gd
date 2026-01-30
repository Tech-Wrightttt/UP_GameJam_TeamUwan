extends Control

@onready var layer1 = $CanvasLayer
@onready var layer2 = $CanvasLayer2
@onready var layer3 = $CanvasLayer3

@onready var anim_player1 = $CanvasLayer/AnimationPlayer
@onready var anim_player2 = $CanvasLayer2/AnimationPlayer
@onready var anim_player3 = $CanvasLayer3/AnimationPlayer

@onready var audio_player = $audio

@onready var sprite = $CanvasLayer/AnimatedSprite2D
@onready var sprite2 = $CanvasLayer2/AnimatedSprite2D
@onready var sprite3 = $CanvasLayer3/AnimatedSprite2D

func _ready() -> void:
	UI.hide_hud()
	layer1.hide()
	layer2.hide()
	layer3.hide()
	
	if audio_player:
		audio_player.play()
	
	sprite.play("hurt")
	sprite2.play("hurt")
	sprite3.play("hurt")
	
	await play_layer_sequence(layer1, anim_player1, 9.5)  
	await play_layer_sequence(layer2, anim_player2, 10) 
	await play_layer_sequence(layer3, anim_player3, 15) 
	
	GameManager.reset_spawn_points()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func play_layer_sequence(layer: CanvasLayer, anim: AnimationPlayer, animation_length: float) -> void:
	layer.show()
	
	anim.queue("typewriter") 
	
	await get_tree().create_timer(animation_length).timeout

	
	layer.hide()
