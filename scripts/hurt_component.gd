# HurtboxComponent.gd
extends Area2D
class_name HurtboxComponent

@export var health_component: HealthComponent

signal hurt(damage: int, direction: Vector2, force: float)

func _ready():
	# This should ALWAYS be monitoring
	monitoring = true
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	# Only take damage from HitboxComponents
	if area is HitboxComponent:
		var hitbox = area as HitboxComponent
		
		# CRITICAL: Make sure it's not our own hitbox!
		if hitbox.get_parent() == get_parent():
			return
		
		print(get_parent().name, " taking damage from: ", hitbox.get_parent().name)
		
		# Calculate direction from hitbox to this hurtbox
		var direction = (global_position - hitbox.global_position).normalized()
		take_damage(hitbox.damage, direction, hitbox.knockback_force)

func take_damage(amount: int, direction: Vector2 = Vector2.ZERO, force: float = 0.0):
	if health_component:
		health_component.take_damage(amount)
		
		# Emit signal for knockback handling
		hurt.emit(amount, direction, force)
	else:
		print("No health component attached!")
