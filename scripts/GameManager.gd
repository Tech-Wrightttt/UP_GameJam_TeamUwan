extends Node

var level_clocks: Array[int] = []  # [level1_clocks, level2_clocks, ...]
var current_clocks: int = 0
var voice_line_played := false  # Add this
var voice_line_played2 := false  # Add this
var voice_line_played3 := false  # Add this
var voice_line_played4 := false  # Add this

var castle1_voiceline_played := false
var castle2_voiceline_played := false
var castle3_voiceline_played := false
var castle4_voiceline_played := false


var overworld1_voiceline_played :=false
var overworld2_voiceline_played :=false
var overworld3_voiceline_played :=false
var overworld4_voiceline_played :=false


var dd_voiceline_played :=false


signal clocks_changed(current: int, total: int)

const TOTAL_CLOCKS := 3
func add_clock() -> void:
	current_clocks += 1
	current_clocks = min(current_clocks, TOTAL_CLOCKS)
	clocks_changed.emit(current_clocks, TOTAL_CLOCKS)

var SCREEN: Dictionary = {
	"width": ProjectSettings.get_setting("display/window/size/viewport_width"),
	"height": ProjectSettings.get_setting("display/window/size/viewport_height"),
	"center": Vector2.ZERO
}


var tutorialLocation: Vector2 = Vector2(1997.452, 329.6545)

var spawn_points: Array[Vector2] = [
	Vector2(-1973.0, 455.0), Vector2(-555.0, 795.0), Vector2(-1343.0, 888.0001),
	Vector2(-1284.0, 882.9999), Vector2(130.0, 1004.0), Vector2(-3025.0, 342.0),
	Vector2(-3040.0, 66.0), Vector2(-2932.0, 410.0), Vector2(-1050.0, 336.0),
	Vector2(19, 20), Vector2(21, 22), Vector2(23, 24),
	Vector2(25, 26)
]

func _ready() -> void:
	SCREEN["center"] = Vector2(
		SCREEN["width"] / 2,
		SCREEN["height"] / 2
	)

func reset_spawn_points() -> void:
	spawn_points.resize(13)
	spawn_points[0] = Vector2(-1973.0, 455.0)
	spawn_points[1] = Vector2(-555.0, 795.0)
	spawn_points[2] = Vector2(-1343.0, 888.0001)
	spawn_points[3] = Vector2(-1284.0, 882.9999)
	spawn_points[4] = Vector2(130.0, 1004.0)
	spawn_points[5] = Vector2(-3025.0, 342.0)
	spawn_points[6] = Vector2(-3040.0, 66.0)
	spawn_points[7] = Vector2(-2932.0, 410.0)
	spawn_points[8] = Vector2(-1050.0, 336.0)
	spawn_points[9] = Vector2(19, 20)
	spawn_points[10] = Vector2(21, 22)
	spawn_points[11] = Vector2(23, 24)
	spawn_points[12] = Vector2(25, 26)
	restart()

	
var defeated_bosses: Dictionary = {}
var player_dead := false

func is_boss_defeated(boss_id: String) -> bool:
	return defeated_bosses.get(boss_id, false)

func mark_boss_defeated(boss_id: String):
	defeated_bosses[boss_id] = true
	
func restart():
	defeated_bosses.clear()
	current_clocks = 0
	player_dead = false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.reset()
	
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
	
