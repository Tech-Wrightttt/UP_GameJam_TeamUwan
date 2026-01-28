extends Control

var pause_toggle = false

func _ready() -> void:
	self.visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ESC"):
		pause_and_unpause()
		
		
func pause_and_unpause():
	pause_toggle = !pause_toggle
	get_tree().paused = pause_toggle
	self.visible = pause_toggle
	


func _on_resume_pressed() -> void:
	pause_and_unpause()


func _on_restart_pressed() -> void:
	pause_and_unpause()
	get_tree().reload_current_scene()


func _on_options_pressed() -> void:
	pass


func _on_quit_to_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
