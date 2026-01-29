extends Area2D
@export var knockback_force := 300.0

func take_hit(damage: int, from_position: Vector2):
	var owner = get_parent()

	var health = owner.find_child("HealthComponent", true, false)
	if health:
		health.take_damage(damage)
	else:
		push_warning("No HealthComponent found for " + owner.name)

	var kb_dir = (owner.global_position - from_position).normalized()

	if owner.has_method("on_hurt"):
		owner.on_hurt(kb_dir, knockback_force)
