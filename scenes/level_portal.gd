extends Area2D

# SET THIS IN THE INSPECTOR!
# If this portal is in Level 1, set this to 1.
# If it's in Level 2, set it to 2.
@export var current_level_number: int = 1

var portal_activated: bool = false  # Prevent multiple triggers

func _ready() -> void:
	# Ensure the collision signal is connected
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# Play the portal animation if it exists
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("idle")
	
	print("Portal ready for Level ", current_level_number)

func _on_body_entered(body: Node2D) -> void:
	# Prevent multiple triggers
	if portal_activated:
		return
	
	# 1. Security Check: Only "Eclipse" can pass.
	if body.name == "Eclipse":
		portal_activated = true  # Lock the portal
		print("Eclipse entered portal for Level ", current_level_number, "!")
		
		# 2. GameManager checks clocks and emits appropriate signal
		GameManager.complete_level(current_level_number)
		
	elif body.name == "Sol" or body.name == "Luna":
		print("Only Eclipse can enter this portal!")
