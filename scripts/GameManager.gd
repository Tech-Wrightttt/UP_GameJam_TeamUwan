extends Node

var SCREEN: Dictionary = {
	"width": ProjectSettings.get_setting("display/window/size/viewport_width"),
	"height": ProjectSettings.get_setting("display/window/size/viewport_height"),
	"center": Vector2.ZERO
}


var tutorialLocation: Vector2 = Vector2(1997.452, 329.6545)
 




func _ready() -> void:
	SCREEN["center"] = Vector2(
		SCREEN["width"] / 2,
		SCREEN["height"] / 2
	)


func setTutorialLocation(location: Vector2) -> void:
	tutorialLocation = location
	



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
	
func fade_out(from: Node, to: String, duration: float, color: Color) -> void:
	var root_control := CanvasLayer.new()
	var color_rect := ColorRect.new()
	var tween := create_tween()

	root_control.process_mode = PROCESS_MODE_ALWAYS
	color_rect.color = Color(0,0,0,0)

	get_tree().root.add_child(root_control)
	root_control.add_child(color_rect)
	color_rect.size = Vector2(SCREEN.width, SCREEN.height)

	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(color_rect, "color", color, duration / 2.0)
	await tween.finished

	# Safely replace scene
	var current_scene := get_tree().current_scene
	if is_instance_valid(current_scene):
		current_scene.queue_free()
		get_tree().root.remove_child(current_scene)

	var new_scene: Node = load(to).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	var tween2 := create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_LINEAR)
	tween2.tween_property(color_rect, "color", color, duration / 2.0)
	await tween2.finished

	root_control.queue_free()
	
