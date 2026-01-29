extends Area2D

@export var damage: int = 10

func _ready():
	monitoring = false
	area_entered.connect(_on_area_entered)

func activate():
	monitoring = true
	print(name, " activated on ", get_parent().name)
	print("Layer:", collision_layer, " Mask:", collision_mask)
	await get_tree().create_timer(2.0).timeout
	monitoring = false

func deactivate():
	monitoring = false
	print(name, " deactivated on ", get_parent().name)

func _on_area_entered(area):
	var my_owner = get_parent()
	var other_owner = area.get_parent()

	# prevent self-hits only
	if my_owner == other_owner:
		return

	# THIS must run for BOTH player and narrator
	if area.has_method("take_hit"):
		area.take_hit(damage)
	
