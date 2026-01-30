extends ProgressBar

@export var health_component: HealthComponent
@export var hide_when_full := false

func _ready():
	if health_component:
		setup_health_component(health_component)

func set_health_component(hc: HealthComponent):
	# Disconnect old signals if any
	if health_component:
		if health_component.health_changed.is_connected(_on_health_changed):
			health_component.health_changed.disconnect(_on_health_changed)
		if health_component.died.is_connected(_on_died):
			health_component.died.disconnect(_on_died)
	
	health_component = hc
	setup_health_component(health_component)

func setup_health_component(hc: HealthComponent):
	if not hc:
		push_error("HealthComponent not assigned to ProgressBar")
		return
	
	max_value = hc.max_health
	value = hc.current_health
	
	if hide_when_full and value >= max_value:
		visible = false
	else:
		visible = true
	
	hc.health_changed.connect(_on_health_changed)
	hc.died.connect(_on_died)

func _on_health_changed(current: int, maximum: int):
	max_value = maximum
	value = current
	
	if hide_when_full:
		visible = current < maximum

func _on_died():
	visible = false
