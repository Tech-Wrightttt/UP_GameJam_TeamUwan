extends Node

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
