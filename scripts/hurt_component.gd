extends Area2D
func _ready():
	area_entered.connect(_on_area_entered)
	print(
	name,
	" HURTBOX Layer:", collision_layer,
	" Mask:", collision_mask
	)
func take_hit(damage: int):
	var health = get_parent().find_child("HealthComponent", true, false)
	if health:
		health.take_damage(damage)
	else:
		push_warning("No HealthComponent found for " + get_parent().name)
func _on_area_entered(area):
	print(
		"HITBOX owner:", get_parent().name,
		"| detected HURTBOX owner:", area.get_parent().name
	)
