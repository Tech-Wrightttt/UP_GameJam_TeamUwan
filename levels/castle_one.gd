extends Node2D


# Called when the node enters the scene tree for the first time.
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite1: AnimatedSprite2D = $AnimatedSprite2D2
@onready var sprite2: AnimatedSprite2D = $AnimatedSprite2D3
@onready var sprite3: AnimatedSprite2D = $AnimatedSprite2D4
func _ready() -> void:
	sprite.play("default")
	sprite1.play("default")
	sprite2.play("default")
	sprite3.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
