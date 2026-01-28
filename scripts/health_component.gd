extends Node
class_name HealthComponent

signal health_changed(new_health: int, max_health: int)
signal died

@export var max_health: int = 100
@export var invincibility_duration: float = 0.5

var current_health: int
var is_invincible: bool = false
var invincibility_timer: float = 0.0

func _ready() -> void:
	current_health = max_health

func _process(delta: float) -> void:
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0.0:
			is_invincible = false

func take_damage(amount: int) -> void:
	if is_invincible:
		return
	
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	print("Took damage: ", amount, " | HP: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()
	else:
		# Start invincibility frames
		is_invincible = true
		invincibility_timer = invincibility_duration

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func die() -> void:
	died.emit()
	print("Died!")

func get_health_percent() -> float:
	return float(current_health) / float(max_health)
