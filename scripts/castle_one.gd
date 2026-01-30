extends Node2D


# Called when the node enters the scene tree for the first time.
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite1: AnimatedSprite2D = $AnimatedSprite2D2
@onready var sprite2: AnimatedSprite2D = $AnimatedSprite2D3
@onready var sprite3: AnimatedSprite2D = $AnimatedSprite2D4
func _ready() -> void:
	AudioManager.transition_music("dungeon")
	$main_character.global_position = GameManager.spawn_points[1]
	sprite.play("default")
	sprite1.play("default")
	sprite2.play("default")
	sprite3.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_towardsTUTORIAL_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		AudioManager.stop_music()
		GameManager.fade_out(get_tree().current_scene,"res://levels/tutoriallevel.tscn",0.8,Color.BLACK)


func _on_towardsc_1_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		AudioManager.stop_music()
		GameManager.fade_out(get_tree().current_scene,"res://levels/castle_two.tscn",0.8,Color.BLACK)


var player

func _on_marker_body_entered(body: Node2D) -> void:
	if body.name == "main_character":
		player = body  # Store the Node2D itself, not body.name
		if player and is_instance_valid(player):
			GameManager.spawn_points[1] = player.global_position
