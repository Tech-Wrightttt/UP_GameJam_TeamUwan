extends Node
class_name HealthComponent

signal health_changed(current: int, maximum: int)
signal died
signal damaged(amount: int)


@export var max_health: int = 100
var current_health: int
var is_dead := false
var last_damage_source: Node = null

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(amount: int,  source: Node = null):
	if is_dead:
		return
	
	current_health = max(current_health - amount, 0)
	last_damage_source = source 
	
	health_changed.emit(current_health, max_health)  
	damaged.emit(amount)
	if current_health == 0:
		is_dead = true
		died.emit()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
