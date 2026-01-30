extends ProgressBar

@export var health_component: HealthComponent
@export var hide_when_full := false

func _ready():
	if not health_component:
		push_error("HealthComponent not assigned to ProgressBar")
		return
	
	max_value = health_component.max_health
	value = health_component.current_health

	if hide_when_full and value >= max_value:
		visible = false
	
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)

func _on_health_changed(current: int, maximum: int):
	max_value = maximum
	value = current
	
	if hide_when_full:
		visible = current < maximum

func _on_died():
	visible = false
