extends CharacterBody2D
@export var uses_sprite := true
@export var move_speed := 200.0
@export var gravity := 980.0  

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fsm = $FiniteStateMachine
@onready var player = get_parent().find_child("main_character", true, false)

var direction: Vector2 = Vector2.ZERO
var can_move := false

func _ready():
	set_physics_process(false)
	fsm.start()

func play_anim(name: String):
	if uses_sprite and sprite:
		sprite.call_deferred("play", name)
	elif animation_player:
		animation_player.play(name)

func set_can_move(value: bool):
	can_move = value
	set_physics_process(value)

func _process(_delta):
	if not player:
		return
	direction = player.global_position - global_position
	sprite.flip_h = direction.x < 0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	if can_move and direction != Vector2.ZERO:
		velocity.x = direction.normalized().x * move_speed
	else:
		velocity.x = 0
	
	move_and_slide()
