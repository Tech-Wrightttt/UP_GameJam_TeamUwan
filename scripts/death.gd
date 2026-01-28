extends State

@export var death_animation := "death"

func enter():
	super()
	boss.set_can_move(false)
	boss.velocity = Vector2.ZERO
	boss.disable_all_hitboxes()
	boss.play_anim(death_animation)
	
	# Disable collision
	boss.set_collision_layer_value(1, false)
	boss.set_collision_mask_value(1, false)
	
	print("Enemy entered death state")
	
	# Wait for death animation, then remove
	await get_tree().create_timer(2.0).timeout
	boss.queue_free()

func exit():
	super()

func transition():
	pass  # No transitions from death
