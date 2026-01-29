extends Node2D

@export var initial_state: NodePath
var current_state: State

func start():
	current_state = get_node(initial_state) as State
	current_state.enter()

func change_state(state_name: String):
	if GameManager.get_is_player_dead():
		return
		
	var new_state := find_child(state_name) as State
	if new_state == null:
		push_error("State not found: " + state_name)
		return
	print("changing to state " + state_name)
	current_state.exit()
	current_state = new_state
	current_state.enter()


func _on_player_detection_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
