extends Area2D

# Get reference to the animation player
@onready var anim_player = $AnimationPlayer
# Get reference to collision shape so we can disable it immediately
@onready var collision_shape = $CollisionShape2D

var collected = false

func _ready():
	# This connects the signal via code so you don't have to do it in the editor
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	# Prevent double triggering if two players hit it at the exact same time
	if collected: return
	if body.is_in_group("player"):
		collected = true
		
		# 1. Disable collision immediately so it can't be triggered again
		# We must use call_deferred for physics properties during a physics callback
		collision_shape.call_deferred("set_disabled", true)
		
		# 2. Add the score (using your existing logic)
		# Using the safer check for the parent node method
		if get_parent().has_method("add_clock"):
			get_parent().add_clock()
			# print("Clock added!")
			
		# 3. Play the collected animation
		# The 'idle' animation stops automatically when a new one plays
		anim_player.play("collected")
		
		# 4. WAIT for animation to finish before deleting
		await anim_player.animation_finished
		
		# 5. Delete object
		queue_free()
