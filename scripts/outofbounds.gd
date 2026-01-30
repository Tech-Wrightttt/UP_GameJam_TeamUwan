extends Area2D

@export var instant_kill := true
@export var damage := 999999

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	# Only affect characters
	if not body is CharacterBody2D:
		return

	var health := body.find_child("HealthComponent", true, false)
	if not health:
		return

	if instant_kill:
		health.take_damage(health.current_health, self)
	else:
		health.take_damage(damage, self)
