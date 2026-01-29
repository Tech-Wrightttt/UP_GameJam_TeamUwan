extends ProgressBar

@export var health_component: HealthComponent
@export var hide_when_full := false
@export var offset_above_enemy := Vector2(0, -40)  # Position above enemy

func _ready():
	if not health_component:
		push_error("HealthComponent not assigned to ProgressBar")
		return
	
	# Set up progress bar appearance
	max_value = health_component.max_health
	value = health_component.current_health
	
	# Position above enemy
	position = offset_above_enemy
	
	# Optional: Hide if at full health
	if hide_when_full and value >= max_value:
		visible = false
	
	# Connect to health changes
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)

func _on_health_changed(current: int, maximum: int):
	max_value = maximum
	value = current
	
	# Show bar when taking damage
	if hide_when_full:
		visible = current < maximum

func _on_died():
	# Optional: fade out or hide on death
	visible = false
