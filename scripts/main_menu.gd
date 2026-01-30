extends Node2D

func _ready() -> void:
	if UI:
		UI.hide_hud()



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/tutoriallevel.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_quit_pressed() -> void:
	
	get_tree().quit()
