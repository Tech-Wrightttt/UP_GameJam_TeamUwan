extends Control

@onready var layer1 = $CanvasLayer
@onready var layer2 = $CanvasLayer2
@onready var layer3 = $CanvasLayer3

@onready var anim_player1 = $CanvasLayer/AnimationPlayer
@onready var anim_player2 = $CanvasLayer2/AnimationPlayer
@onready var anim_player3 = $CanvasLayer3/AnimationPlayer

@onready var audio_player = $audio

func _ready() -> void:
	# Hide all layers at the start just in case
	layer1.hide()
	layer2.hide()
	layer3.hide()
	
	if audio_player:
		audio_player.play()
		
	await play_layer_sequence(layer1, anim_player1, 10.5)  
	await play_layer_sequence(layer2, anim_player2, 10) 
	await play_layer_sequence(layer3, anim_player3, 8) 
	
	get_tree().change_scene_to_file("res://levels/main_menu.tscn")

func play_layer_sequence(layer: CanvasLayer, anim: AnimationPlayer, animation_length: float) -> void:
	layer.show()
	
	
	anim.queue("typewriter") 
	# Wait for animation to finish OR use timer
	await get_tree().create_timer(animation_length).timeout
	
	# Optional: Wait a bit before hiding
	await get_tree().create_timer(1.0).timeout
	
	layer.hide()
