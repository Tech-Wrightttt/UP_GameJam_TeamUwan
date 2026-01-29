extends Area2D

@export var damage: int = 10

func _ready():
	monitoring = false
	area_entered.connect(_on_area_entered)

func activate():
	monitoring = false
	
	if GameManager.get_is_player_dead():
		return
		
	await get_tree().process_frame # force clean reset
	monitoring = true
	print(name, " activated on ", get_parent().name)
	print("Layer:", collision_layer, " Mask:", collision_mask)

func deactivate():
	monitoring = false
	print(name, " deactivated on ", get_parent().name)

func _on_area_entered(area):
	if GameManager.get_is_player_dead():
		return
	
	var my_owner = get_parent()
	var other_owner = area.get_parent()

	if my_owner == other_owner:
		return

	if area.has_method("take_hit"):
		area.take_hit(damage, my_owner.global_position)
