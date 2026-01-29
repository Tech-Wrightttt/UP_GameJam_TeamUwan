extends Area2D

@export var next_map: String = "res://maps/forest.tscn"
@export var exit_direction: String = "right"  # "left", "right", "up", "down"
@export var required_boss_defeated: String = ""  # Optional: require boss defeat

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Check if boss requirement is met
		if required_boss_defeated != "":
			if not GameManager.is_boss_defeated(required_boss_defeated):
				# Show message or play sound
				print("Boss not defeated yet!")
				return
		
		# Save player state
		GameManager.save_player_state(body)
		GameManager.player_exit_direction = exit_direction
		
		# Get entry point for next map
		var entry_point = GameManager.get_entry_point_name(exit_direction)
		
		# Change map
		GameManager.change_map(next_map, entry_point)

# Optional: Draw in editor for visibility
func _draw():
	if Engine.is_editor_hint():
		draw_rect(Rect2(-Vector2.ONE * 8, Vector2.ONE * 16), Color(1, 0.5, 0, 0.3))
