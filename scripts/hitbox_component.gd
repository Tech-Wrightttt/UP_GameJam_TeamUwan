# HitboxComponent.gd
extends Area2D
class_name HitboxComponent

@export var damage := 10
@export var knockback_force := 300.0
@export var knockback_direction := Vector2.ZERO  # If zero, uses direction from attacker to target

func _ready():
	area_entered.connect(_on_area_entered)
	# Make sure monitoring is OFF by default
	monitoring = false

func _on_area_entered(area: Area2D):
	if not monitoring:
		return
		
	# Only damage HurtboxComponents
	if area is HurtboxComponent:
		var hurtbox = area as HurtboxComponent
		
		# CRITICAL: Don't hit our own hurtbox!
		if hurtbox.get_parent() == get_parent():
			return
			
		print("Hitbox dealing damage to: ", hurtbox.get_parent().name)
		
		# Calculate knockback direction if not set
		var kb_dir = knockback_direction
		if kb_dir == Vector2.ZERO:
			kb_dir = (hurtbox.global_position - global_position).normalized()
		
		hurtbox.take_damage(damage, kb_dir, knockback_force)
		
		# Disable after one hit to prevent multiple hits per attack
		monitoring = false
