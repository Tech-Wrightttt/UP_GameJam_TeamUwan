extends Node2D


# Sound effect audio files
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
	],
	"dash": [
		preload("res://soundFX/player/dash.wav")
	],
}

# Music tracks
const MUSIC = {
	"dungeon": preload("res://soundFX/music/dungeon_backgroud_loop.mp3"),
	"overworld": preload("res://soundFX/music/overworld_backgroud_loop.mp3"),
	"darkworld": preload("res://soundFX/music/darkdimension_backgroud_loop.mp3"),
	"bossfight": preload("res://soundFX/music/bossfight_music.mp3")
}

# Audio playback settings (pitch variation and volume)
const AUDIO_CONFIGS = {
	"sword_swing": {
		"pitch_min": 0.95,
		"pitch_max": 1.05,
		"volume_db": -10.0
	},
	"dash": {
		"pitch_min": 0.95,
		"pitch_max": 1.05,
		"volume_db": -10.0
	},
	"damage": {
		"pitch_min": 1.0,
		"pitch_max": 1.0,
		"volume_db": 0.0
	},
	"walk_overworld": {
		"pitch_min": 0.98,
		"pitch_max": 1.02,
		"volume_db": -20.0
	},
	"music": {
		"pitch_min": 1.0,
		"pitch_max": 1.0,
		"volume_db": -15.0
	}
}

# Walking sound settings
const WALK_INTERVAL: float = 0.45  # Time between walking sounds (seconds)

# Music state
var current_music_player: AudioStreamPlayer = null
var current_music_state: String = ""

# Walking state
var walking_timer: Timer = null
var is_walking: bool = false



func _ready() -> void:
	_setup_walking_timer()

func _setup_walking_timer() -> void:
	walking_timer = Timer.new()
	add_child(walking_timer)
	walking_timer.wait_time = WALK_INTERVAL
	walking_timer.timeout.connect(_on_walking_timer_timeout)

# Play a sound effect (non-positional)
func play_sound(sound_key: String) -> void:
	if not PLAYER_SOUNDS.has(sound_key):
		push_error("Sound key '%s' not found" % sound_key)
		return
	
	var config = AUDIO_CONFIGS.get(sound_key, {})
	var sound_array = PLAYER_SOUNDS[sound_key]
	var stream = sound_array.pick_random() if sound_array is Array else sound_array
	
	_create_and_play_sound(stream, config)

# Start playing walking sounds on a loop
func start_walking() -> void:
	if is_walking:
		return
	
	is_walking = true
	play_sound("walk_overworld")  # Play first step immediately
	walking_timer.start()

# Stop playing walking sounds
func stop_walking() -> void:
	is_walking = false
	walking_timer.stop()

func _on_walking_timer_timeout() -> void:
	if is_walking:
		play_sound("walk_overworld")

# Transition to a new music track with fade in/out
func transition_music(music_state: String) -> void:
	if music_state == current_music_state:
		return
	
	if not MUSIC.has(music_state):
		push_error("Music state '%s' not found" % music_state)
		return
	
	# Fade out old music
	if current_music_player:
		_fade_out_music(current_music_player)
	
	# Create and fade in new music
	current_music_state = music_state
	current_music_player = _create_music_player(MUSIC[music_state])
	_fade_in_music(current_music_player)

# Stop the currently playing music
func stop_music() -> void:
	if current_music_player:
		_fade_out_music(current_music_player)
		current_music_player = null
		current_music_state = ""

# Create and play a non-positional sound
func _create_and_play_sound(stream: AudioStream, config: Dictionary) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = stream
	player.pitch_scale = randf_range(
		config.get("pitch_min", 1.0),
		config.get("pitch_max", 1.0)
	)
	player.volume_db = config.get("volume_db", 0.0)
	player.finished.connect(player.queue_free)
	
	player.play()

# Create a music player (starts silent)
func _create_music_player(stream: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = stream
	player.volume_db = -80.0  # Start silent for fade-in
	player.bus = "Music"
	
	return player

# Fade in music over specified duration
func _fade_in_music(player: AudioStreamPlayer, duration: float = 1.0) -> void:
	player.play()
	var tween = create_tween()
	tween.tween_property(player, "volume_db", AUDIO_CONFIGS["music"]["volume_db"], duration)

# Fade out music over specified duration, then free the player
func _fade_out_music(player: AudioStreamPlayer, duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration)
	tween.tween_callback(player.queue_free)
