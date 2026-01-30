extends State

@export var death_animation := "death"

func enter():
	super()
	boss.set_can_move(false)
	boss.velocity = Vector2.ZERO
	
	boss.hurtbox.monitoring = false
	boss.hurtbox.monitorable = false
	
	boss.play_anim(death_animation)  # AnimatedSprite2D animation ni
	if boss.animation_player.has_animation(death_animation):
		boss.animation_player.play(death_animation)  # AnimationPlayer ni
	else:
		print("Warning: no animationplayer animation for death")
	
	boss.set_collision_layer_value(1, false)
	boss.set_collision_layer_value(2, false)
	boss.set_collision_mask_value(1, false)
	boss.set_collision_mask_value(2, false)
	
	await get_tree().create_timer(2).timeout
	boss.queue_free()

func exit():
	super()

func _physics_process(delta):
	super(delta)
	boss.velocity = Vector2.ZERO

func transition():
	pass
