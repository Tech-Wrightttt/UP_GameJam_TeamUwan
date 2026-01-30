extends Node2D

# GUIDE FOR AUDIO PLAYING
# Player 			- AudioManager.play_sword_swing(player)
# Music transitions - AudioManager.transition_music("dungeon")

const PLAYER_SOUNDS = {
	"sword_swing": [
		preload("res://soundFX/player/swordswing_1.wav"),
		preload("res://soundFX/player/swordswing_2.wav"),
		preload("res://soundFX/player/swordswing_3.wav"),
		preload("res://soundFX/player/swordswing_4.wav"),
		preload("res://soundFX/player/swordswing_5.wav")
	],
	"damage": [
		preload("res://soundFX/player/player_hurt.mp3")
	],
	"walk_overworld": [
		preload("res://soundFX/player/walking_overworld_1.mp3"),
		preload("res://soundFX/player/walking_overworld_2.mp3"),
		preload("res://soundFX/player/walking_overworld_3.mp3")
	]
}

const ENEMY_SOUNDS = {
	
}

const MUSIC = {
	"dungeon": preload("res://soundFX/music/dungeon_backgroud_loop.mp3"),
	"overworld": preload("res://soundFX/music/overworld_backgroud_loop.mp3"),
	"darkworld": preload("res://soundFX/music/darkdimension_backgroud_loop.mp3"),
	"bossfight": preload("res://soundFX/music/bossfight_music.mp3")
}

const AUDIO_CONFIGS = {
	"sword_swing": {
		"pitch_min": 0.95,
		"pitch_max": 1.05,
		"volume_db": 0.0
	},
	"player_damage": {
		"pitch_min": 1.0,
		"pitch_max": 1.0,
		"volume_db": 0.0
	},
	"music": {
		"pitch_min": 1.0,
		"pitch_max": 1.0,
		"volume_db": -5.0
	}
}

var current_music_player: AudioStreamPlayer = null
var current_music_state: String = ""
var player_node: Node2D = null  # Reference to the player

# Set the player reference (call this once during game initialization)
func set_player(player: Node2D):
	player_node = player

# Main interface - play any sound effect at player position
func play_sound(sound_key: String):
	if not player_node:
		push_error("Player node not set. Call AudioManager.set_player() first.")
		return
	
	if not PLAYER_SOUNDS.has(sound_key):
		push_error("Sound key '%s' not found" % sound_key)
		return
	
	var config = AUDIO_CONFIGS.get(sound_key, {})
	var sound_array = PLAYER_SOUNDS[sound_key]
	var stream = sound_array.pick_random() if sound_array is Array else sound_array
	
	_create_and_play_2d(stream, player_node, config)

# Play sound at specific position
func play_sound_at(sound_key: String, position: Vector2):
	if not PLAYER_SOUNDS.has(sound_key):
		push_error("Sound key '%s' not found" % sound_key)
		return
	
	var config = AUDIO_CONFIGS.get(sound_key, {})
	var sound_array = PLAYER_SOUNDS[sound_key]
	var stream = sound_array.pick_random() if sound_array is Array else sound_array
	
	_create_and_play_2d_at_position(stream, position, config)

# Music state machine
func transition_music(music_state: String):
	if music_state == current_music_state:
		return
	
	if not MUSIC.has(music_state):
		push_error("Music state '%s' not found" % music_state)
		return
	
	if current_music_player:
		_fade_out_music(current_music_player)
	
	current_music_state = music_state
	current_music_player = _create_music_player(MUSIC[music_state])
	_fade_in_music(current_music_player)

func stop_music():
	if current_music_player:
		_fade_out_music(current_music_player)
		current_music_player = null
		current_music_state = ""

# Internal helper methods
func _create_and_play_2d(stream: AudioStream, parent: Node2D, config: Dictionary):
	var player := AudioStreamPlayer2D.new()
	parent.add_child(player)
	
	player.stream = stream
	player.pitch_scale = randf_range(
		config.get("pitch_min", 1.0),
		config.get("pitch_max", 1.0)
	)
	player.volume_db = config.get("volume_db", 0.0)
	player.global_position = parent.global_position
	player.finished.connect(player.queue_free)
	
	player.play()

func _create_and_play_2d_at_position(stream: AudioStream, position: Vector2, config: Dictionary):
	var player := AudioStreamPlayer2D.new()
	add_child(player)
	
	player.stream = stream
	player.pitch_scale = randf_range(
		config.get("pitch_min", 1.0),
		config.get("pitch_max", 1.0)
	)
	player.volume_db = config.get("volume_db", 0.0)
	player.global_position = position
	player.finished.connect(player.queue_free)
	
	player.play()

func _create_music_player(stream: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = stream
	player.volume_db = -80.0
	player.bus = "Music"
	
	return player

func _fade_in_music(player: AudioStreamPlayer, duration: float = 1.0):
	player.play()
	var tween = create_tween()
	tween.tween_property(player, "volume_db", AUDIO_CONFIGS["music"]["volume_db"], duration)

func _fade_out_music(player: AudioStreamPlayer, duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration)
	tween.tween_callback(player.queue_free)
