extends CharacterBody2D

# ─── CONFIG ─────────────────────────────────────────────
@export var uses_sprite := true
@export var move_speed := 40.0

# ─── NODES ──────────────────────────────────────────────
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fsm = $FiniteStateMachine
@onready var player = get_parent().find_child("player")

# ─── STATE ──────────────────────────────────────────────
var direction: Vector2 = Vector2.ZERO
var can_move := false

# ─── LIFECYCLE ──────────────────────────────────────────
func _ready():
	set_physics_process(false)
	fsm.start() # FSM starts ONLY after boss is ready

# ─── ANIMATION ADAPTER ──────────────────────────────────
func play_anim(name: String):
	if uses_sprite and sprite:
		sprite.call_deferred("play", name)
	elif animation_player:
		animation_player.play(name)

# ─── MOVEMENT CONTROL (CALLED BY STATES) ─────────────────
func set_can_move(value: bool):
	can_move = value
	set_physics_process(value)

# ─── ORIENTATION ─────────────────────────────────────────
func _process(_delta):
	if not player:
		return

	direction = player.global_position - global_position
	sprite.flip_h = direction.x < 0

# ─── PHYSICS ────────────────────────────────────────────
func _physics_process(delta):
	if not can_move:
		return

	if direction == Vector2.ZERO:
		return

	velocity = direction.normalized() * move_speed
	move_and_slide()
