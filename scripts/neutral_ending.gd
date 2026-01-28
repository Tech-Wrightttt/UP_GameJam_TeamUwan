extends Control

@onready var layer1 = $CanvasLayer
@onready var layer2 = $CanvasLayer2

@onready var anim_player1 = $CanvasLayer/AnimationPlayer
@onready var anim_player2 = $CanvasLayer2/AnimationPlayer

@onready var audio_player = $audio

func _ready() -> void:
	# Hide all layers at the start just in case
	layer1.hide()
	layer2.hide()
	
	if audio_player:
		audio_player.play()
	
	await play_layer_sequence(layer1, anim_player1, 7.0)  
	
	await play_layer_sequence(layer2, anim_player2, 10.0) 
	
	get_tree().change_scene_to_file("res://levels/title_screen.tscn")

func play_layer_sequence(layer: CanvasLayer, anim: AnimationPlayer, animation_length: float) -> void:
	layer.show()
	
	# Play the typewriter animation
	anim.play("typewriter")
	
	# Wait for the animation to finish (or use timer if animation_finished doesn't work)
	await get_tree().create_timer(animation_length).timeout
	
	await get_tree().create_timer(1.0).timeout  # 1 second pause
	
	layer.hide()
