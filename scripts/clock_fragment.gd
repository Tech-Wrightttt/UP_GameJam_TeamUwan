extends Area2D

# Get reference to the animation player
@onready var anim_player = $AnimationPlayer
# Get reference to collision shape so we can disable it immediately
@onready var collision_shape = $CollisionShape2D

var collected = false

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if collected: return
	if body.is_in_group("player"):
		collected = true
		
		collision_shape.call_deferred("set_disabled", true)
		
		GameManager.add_clock()			

		anim_player.play("collected")
		
		await anim_player.animation_finished

		queue_free()
