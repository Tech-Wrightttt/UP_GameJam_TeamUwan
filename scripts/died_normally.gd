extends Control

@onready var layer1 = $CanvasLayer

@onready var anim_player1 = $CanvasLayer/AnimationPlayer

func _ready() -> void:
	# Hide all layers at the start just in case
	layer1.hide()
	
	await play_layer_sequence(layer1, anim_player1)
	
	get_tree().change_scene_to_file("res://levels/tutoriallevel.tscn")

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
