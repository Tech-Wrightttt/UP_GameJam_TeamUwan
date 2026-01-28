extends Control

@onready var layer1 = $CanvasLayer
@onready var layer2 = $CanvasLayer2
@onready var layer3 = $CanvasLayer3

@onready var anim_player1 = $CanvasLayer/AnimationPlayer
@onready var anim_player2 = $CanvasLayer2/AnimationPlayer
@onready var anim_player3 = $CanvasLayer3/AnimationPlayer

@onready var audio_player = $audio

func _ready() -> void:
	# Hide all layers at the start
	layer1.hide()
	layer2.hide()
	layer3.hide()
	
	# Play audio if available
	if audio_player:
		audio_player.play()
	
	# Play all sequences
	await play_layer_sequence(layer1, anim_player1, 8.7)  
	await play_layer_sequence(layer2, anim_player2, 7) 
	await play_layer_sequence(layer3, anim_player3, 9) 
	
	# Change to tutorial level AFTER sequences
	get_tree().change_scene_to_file("res://levels/tutoriallevel.tscn")

func play_layer_sequence(layer: CanvasLayer, anim: AnimationPlayer, animation_length: float) -> void:
	layer.show()
	
	# Play the animation (not queue)
	anim.play("typewriter")
	
	# Wait for animation to finish OR use timer
	await get_tree().create_timer(animation_length).timeout
	
	# Optional: Wait a bit before hiding
	await get_tree().create_timer(1.0).timeout
	
	layer.hide()
