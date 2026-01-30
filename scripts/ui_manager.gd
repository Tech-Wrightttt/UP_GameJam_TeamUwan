extends CanvasLayer

@onready var player_healthbar: ProgressBar = $Display/HealthBar

func connect_player_health(health: HealthComponent):
	if not health:
		push_error("UI: No HealthComponent passed")
		return

	player_healthbar.max_value = health.max_health
	player_healthbar.value = health.current_health

	health.health_changed.connect(_on_player_health_changed)
	health.died.connect(_on_player_died)

func _on_player_health_changed(current: int, max: int):
	player_healthbar.max_value = max
	player_healthbar.value = current

func _on_player_died():
	player_healthbar.value = 0
	
func show_hud():
	visible = true

func hide_hud():
	visible = false
