extends Node

var SCREEN: Dictionary = {
	"width": ProjectSettings.get_setting("display/window/size/viewport_width"),
	"height": ProjectSettings.get_setting("display/window/size/viewport_height"),
	"center": Vector2.ZERO
}

func _ready() -> void:
	SCREEN["center"] = Vector2(
		SCREEN["width"] / 2,
		SCREEN["height"] / 2
	)

	

var defeated_bosses: Dictionary = {}
var player_dead := false

func is_boss_defeated(boss_id: String) -> bool:
	return defeated_bosses.get(boss_id, false)

func mark_boss_defeated(boss_id: String):
	defeated_bosses[boss_id] = true
	print("Boss defeated:", boss_id)
	
func set_is_player_dead(is_dead: bool):
	player_dead = is_dead

func get_is_player_dead():
	return player_dead
	
	
func fade_out(from, to, duration: float, color: Color) -> void:
	var rootControl = CanvasLayer.new()
	var colorRect = ColorRect.new()
	var tween = get_tree().create_tween()
	
	rootControl.set_process_mode(PROCESS_MODE_ALWAYS)
	colorRect.color = Color(0, 0, 0, 0)

	get_tree().get_root().add_child(rootControl)
	rootControl.add_child(colorRect)

	colorRect.set_size(Vector2(SCREEN.width, SCREEN.height))

	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(colorRect, "color", color, duration / 2.0)

	var root = get_tree().root
	await tween.finished

	from.queue_free()

	var new_scene = load(to).instantiate()
	get_tree().get_root().add_child(new_scene)

	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_LINEAR)
	tween2.tween_property(colorRect, "color", Color(0, 0, 0, 0), duration / 2.0)

	await tween2.finished

	get_tree().set_current_scene(new_scene)
	rootControl.queue_free()
