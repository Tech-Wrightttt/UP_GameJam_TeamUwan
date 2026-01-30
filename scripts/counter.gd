extends Label

func _ready():
	_update(GameManager.current_clocks, GameManager.TOTAL_CLOCKS)

	GameManager.clocks_changed.connect(_update)

func _update(current: int, total: int):
	text = "%d / %d" % [current, total]
