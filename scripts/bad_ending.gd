extends Control

@onready var layer1 = $CanvasLayer
@onready var layer2 = $CanvasLayer2
@onready var layer3 = $CanvasLayer3

@onready var anim_player1 = $CanvasLayer/AnimationPlayer
@onready var anim_player2 = $CanvasLayer2/AnimationPlayer
@onready var anim_player3 = $CanvasLayer3/AnimationPlayer


@onready var sprite = $CanvasLayer/AnimatedSprite2D
@onready var sprite2 = $CanvasLayer2/AnimatedSprite2D
@onready var sprite3 = $CanvasLayer3/AnimatedSprite2D

func _ready() -> void:
	# Hide all layers at the start just in case
	layer1.hide()
	layer2.hide()
	layer3.hide()
	
	sprite.play("hurt")
	sprite2.play("hurt")
	sprite3.play("hurt")
	
	await play_layer_sequence(layer1, anim_player1)
	await play_layer_sequence(layer2, anim_player2)
	await play_layer_sequence(layer3, anim_player3)
	
	get_tree().change_scene_to_file("res://levels/title_screen.tscn")

func play_layer_sequence(layer: CanvasLayer, anim: AnimationPlayer) -> void:
	layer.show()
	
	## Start from black, then fade to show the text
	#anim.play("fade_in") 
	# Play typewriter immediately or shortly after
	anim.queue("typewriter") 
	
	# Wait for the player to read (7 seconds)
	await get_tree().create_timer(7.0).timeout
	
	## Fade back to black
	#anim.play("fade_out")
	#await anim.animation_finished
	
	layer.hide()
