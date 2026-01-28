extends State

@onready var collision = $"../../PlayerDetection/CollisionShape2D"

var player_entered: bool = false:
	set(value):
		player_entered = value
		collision.set_deferred("disabled", value)

func enter():
	super()
	print("IDLE STATE")
	get_parent().get_parent().play_anim("idle")

func _on_player_detection_body_entered(body):
	if not body.is_in_group("player"):
		return

	print("PLAYER detected:", body.name)
	player_entered = true

func transition() :
	if player_entered:
		get_parent().change_state("follow")
