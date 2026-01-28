extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite1: AnimatedSprite2D = $AnimatedSprite2D2
@onready var sprite2: AnimatedSprite2D = $AnimatedSprite2D3
@onready var sprite3: AnimatedSprite2D = $AnimatedSprite2D4
@onready var sprite4: AnimatedSprite2D = $AnimatedSprite2D5
@onready var player: AnimatedSprite2D = $AnimatedSprite2D6


func _ready() -> void:
	sprite.play("default")
	sprite1.play("default")
	sprite2.play("default")
	sprite3.play("default")
	sprite4.play("default")
	player.play("default")

	# player light
	add_player_light(player)



func add_player_light(target: Node2D) -> void:
	var light := PointLight2D.new()

	var gradient := Gradient.new()
	gradient.colors = [Color.WHITE, Color(1, 1, 1, 0)]

	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.width = 512
	texture.height = 512

	light.texture = texture
	light.texture_scale = 3.0
	light.energy = 0.8
	light.color = Color(0.9, 0.9, 1.0)
	light.blend_mode = Light2D.BLEND_MODE_ADD

	target.add_child(light)
