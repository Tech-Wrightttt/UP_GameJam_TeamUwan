extends Area2D

func _ready():
	print("Portal script initialized")
	
	## Set collision detection
	#collision_layer = 0
	#collision_mask = 1
	
	## Add pulsing effect to sprite if it exists
	#var sprite = get_node_or_null("Sprite2D")
	#if sprite:
		#var tween = create_tween()
		#tween.set_loops()
		#tween.tween_property(sprite, "modulate:a", 0.5, 1.0)
		#tween.tween_property(sprite, "modulate:a", 1.0, 1.0)
	
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("enter portal")
		if body.name == "main_character":
			AudioManager.stop_music()
			GameManager.fade_out(get_tree().current_scene,"res://levels/dimension20_one.tscn",0.8,Color.BLACK)
