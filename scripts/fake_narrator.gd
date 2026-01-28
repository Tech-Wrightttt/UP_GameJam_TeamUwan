extends CharacterBody2D

@export var uses_sprite := true
@export var move_speed := 200.0
@export var gravity := 980.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fsm = $FiniteStateMachine
@onready var player = get_parent().find_child("main_character", true, false)
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_attack1: HitboxComponent = $Hitbox_Attack1
@onready var hitbox_attack2: HitboxComponent = $Hitbox_Attack2

var direction: Vector2 = Vector2.ZERO
var can_move := false
var is_dead := false  # Prevent multiple death triggers

func _ready():
	set_physics_process(false)
	
	if health_component:
		health_component.died.connect(_on_enemy_died)
		print("Enemy health: ", health_component.current_health, "/", health_component.max_health)
	
	disable_all_hitboxes()
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
	if is_dead or not player:
		return
	direction = player.global_position - global_position
	sprite.flip_h = direction.x < 0

func _physics_process(delta):
	if is_dead:
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	if can_move and direction != Vector2.ZERO:
		velocity.x = direction.normalized().x * move_speed
	else:
		velocity.x = 0
	
	move_and_slide()

func _on_enemy_died() -> void:
	if is_dead:
		return  # Prevent multiple death calls
		
	is_dead = true
	print("Enemy died! Health: ", health_component.current_health)
	fsm.change_state("death")

func enable_hitbox_attack1() -> void:
	disable_all_hitboxes()
	if hitbox_attack1:
		hitbox_attack1.monitoring = true
		print("Enabled hitbox attack1")

func enable_hitbox_attack2() -> void:
	disable_all_hitboxes()
	if hitbox_attack2:
		hitbox_attack2.monitoring = true
		print("Enabled hitbox attack2")

func disable_all_hitboxes() -> void:
	if hitbox_attack1:
		hitbox_attack1.monitoring = false
	if hitbox_attack2:
		hitbox_attack2.monitoring = false
