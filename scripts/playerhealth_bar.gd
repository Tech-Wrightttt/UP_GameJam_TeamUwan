extends ProgressBar

@export var hide_when_full := false
var health_component: HealthComponent

func bind(health: HealthComponent):
	if not health:
		push_error("HealthBar: Tried to bind null HealthComponent")
		return

	health_component = health

	max_value = health.max_health
	value = health.current_health

	if hide_when_full:
		visible = value < max_value

	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)

	print("✅ HealthBar bound to HealthComponent")

func _on_health_changed(current: int, maximum: int):
	max_value = maximum
	value = current

	if hide_when_full:
		visible = current < maximum

func _on_died():
	visible = false
