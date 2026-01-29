extends CharacterBody2D

# =========================
# MOVEMENT TUNING
# =========================
const SPEED = 300.0
const attackSPEED = 400.0
const ACCELERATION = 2000.0
const FRICTION = 1800.0
const AIR_RESISTANCE = 400.0

# =========================
# JUMP TUNING
# =========================
const JUMP_VELOCITY = -400.0
const JUMP_CUT_MULTIPLIER = 0.5
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.15

# =========================
# ROLL / BLOCK
# =========================
const ROLL_DURATION = 0.4
const BLOCK_HOLD_SPEED = 40.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# =========================
# STATES
# =========================
enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ROLL,
	BLOCK,
	ATTACK
}

var current_state: PlayerState = PlayerState.IDLE
var previous_state: PlayerState = PlayerState.IDLE

# =========================
# TIMERS
# =========================
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var roll_timer := 0.0
var attack_timer := 0.0

var last_direction := 1

var attack_index: int = 0
var attacks := ["attack1", "attack2", "attack3"]
var combo_window: float = 0.4  # Grace period AFTER attack ends
var combo_timer: float = 0.0
var is_attacking: bool = false
var combo_pending: bool = false

@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_attack1: Area2D = $Hitbox_Attack1
@onready var hitbox_attack2: Area2D = $Hitbox_Attack2
@onready var hitbox_attack3: Area2D = $Hitbox_Attack3

@export var effects_animation_player: AnimationPlayer  
@export var knockback_decay := 6.0
var knockback_velocity := Vector2.ZERO
var is_hurt := false

func _ready() -> void:
	transition_to(PlayerState.IDLE)
	
	health_component.died.connect(_on_player_died)
	
	hitbox_attack1.deactivate()
	hitbox_attack2.deactivate()
	hitbox_attack3.deactivate()

func start_attack(anim: String):
	is_attacking = true
	transition_to(PlayerState.ATTACK)
	velocity.x = last_direction * attackSPEED
	sprite.play(anim)
	animation_player.play(anim) 

func _on_player_died():
	print("Player died!")
	GameManager.set_is_player_dead(true)
	
	# Stop all animations
	animation_player.stop(false)
	if effects_animation_player:
		effects_animation_player.stop(false)
	
	# Disable hitboxes
	hitbox_attack1.deactivate()
	hitbox_attack1.monitorable = false
	hitbox_attack2.deactivate()
	hitbox_attack2.monitorable = false
	hitbox_attack3.deactivate()
	hitbox_attack3.monitorable = false
	
	# Disable hurtbox
	$Hurtbox.monitoring = false
	$Hurtbox.monitorable = false
	
	set_physics_process(false)
	sprite.play("death")  # If you have a death animation
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if not sprite.animation.begins_with("attack"):
		return
	
	if combo_pending:
		combo_pending = false
		start_attack(attacks[attack_index - 1])
	else:
		combo_timer = combo_window
		is_attacking = false
		
		if not is_on_floor():
			transition_to(PlayerState.FALL)
		else:
			var dir = Input.get_axis("left", "right")
			transition_to(PlayerState.RUN if dir != 0 else PlayerState.IDLE)

func _on_health_changed(new_health: int, max_health: int) -> void:
	print("Player health: ", new_health, "/", max_health)

# =========================
# MAIN LOOPS
# =========================
func _physics_process(delta: float) -> void:
	update_timers(delta)
	handle_input()
	update_state(delta)
	apply_knockback(delta)
	move_and_slide()

func _process(_delta: float) -> void:
	if current_state != previous_state:
		print(PlayerState.keys()[current_state])
		previous_state = current_state
		
	if combo_timer > 0.0 and not is_attacking:
		combo_timer -= _delta
		if combo_timer <= 0.0:
			attack_index = 0  # Reset after window

func apply_knockback(delta: float) -> void:
	if knockback_velocity.length() > 1.0:
		velocity.x = knockback_velocity.x
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_decay * delta)
	else:
		knockback_velocity = Vector2.ZERO
		is_hurt = false

# =========================
# TIMERS
# =========================
func update_timers(delta: float) -> void:
	coyote_timer -= delta
	jump_buffer_timer -= delta
	roll_timer -= delta
	if attack_timer > 0:
		attack_timer -= delta

	if is_on_floor():
		coyote_timer = COYOTE_TIME

# =========================
# INPUT
# =========================


func handle_input() -> void:
	# =====================
	# ATTACKS (highest priority)
	# =====================
	
	if Input.is_action_just_pressed("attack1"):
		if not is_attacking:
			attack_index = 1
			start_attack(attacks[attack_index - 1])
		else:
			# Queue next attack
			attack_index = (attack_index % attacks.size()) + 1
			combo_pending = true





	# =====================
	# JUMP
	# =====================
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	# =====================
	# ROLL
	# =====================
	if Input.is_action_just_pressed("roll") and is_on_floor():
		transition_to(PlayerState.ROLL)
		return

	# =====================
	# BLOCK TOGGLE (G)
	# =====================
	if Input.is_action_just_pressed("block"):
		if current_state == PlayerState.BLOCK:
			transition_to(PlayerState.IDLE)
		else:
			transition_to(PlayerState.BLOCK)
		return

	# =====================
	# FACING
	# =====================
	if current_state != PlayerState.BLOCK: # block prevents direction changes
		if Input.is_action_pressed("left"):
			sprite.flip_h = true
			last_direction = -1
			$Hitbox_Attack1/attack1.position.x = -24
			$Hitbox_Attack2/attack2.position.x = -23
			$Hitbox_Attack3/attack3.position.x = -25
		elif Input.is_action_pressed("right"):
			sprite.flip_h = false
			last_direction = 1
			$Hitbox_Attack1/attack1.position.x = 24
			$Hitbox_Attack2/attack2.position.x = 23
			$Hitbox_Attack3/attack3.position.x = 25

# =========================
# STATE MACHINE
# =========================
func update_state(delta: float) -> void:
	match current_state:
		PlayerState.IDLE:
			state_idle(delta)
		PlayerState.RUN:
			state_run(delta)
		PlayerState.JUMP:
			state_jump(delta)
		PlayerState.FALL:
			state_fall(delta)
		PlayerState.ROLL:
			state_roll(delta)
		PlayerState.BLOCK:
			state_block(delta)
		PlayerState.ATTACK:
			state_attack(delta)

# =========================
# STATES
# =========================
func state_idle(delta: float) -> void:
	apply_friction(delta)
	apply_gravity(delta)

	if try_jump():
		return

	var dir = Input.get_axis("left", "right")
	if not is_on_floor():
		transition_to(PlayerState.FALL)
	elif dir != 0:
		transition_to(PlayerState.RUN)

func state_run(delta: float) -> void:
	apply_horizontal_movement(delta)
	apply_gravity(delta)

	if try_jump():
		return

	var dir = Input.get_axis("left", "right")
	if not is_on_floor():
		transition_to(PlayerState.FALL)
	elif dir == 0:
		transition_to(PlayerState.IDLE)

func state_jump(delta: float) -> void:
	apply_horizontal_movement(delta)
	apply_gravity(delta)

	if velocity.y >= 0:
		transition_to(PlayerState.FALL)

func state_fall(delta: float) -> void:
	apply_horizontal_movement(delta)
	apply_gravity(delta)

	if try_jump():
		return

	if is_on_floor():
		var dir = Input.get_axis("left", "right")
		transition_to(PlayerState.RUN if dir != 0 else PlayerState.IDLE)

func state_roll(delta: float) -> void:
	velocity.x = last_direction * SPEED * 1.4
	apply_gravity(delta)

	if roll_timer <= 0:
		transition_to(PlayerState.IDLE)

func state_block(delta: float) -> void:
	# Prevent horizontal input
	velocity.x = move_toward(velocity.x, 0, BLOCK_HOLD_SPEED)
	apply_gravity(delta)

# =========================
# ATTACK STATE
# =========================
func state_attack(delta: float) -> void:
	var _decel := 0.0 if not is_on_floor() else FRICTION
	velocity.x = move_toward(velocity.x, 0, _decel * delta)
	apply_gravity(delta)

# =========================
# ACTIONS
# =========================
func try_jump() -> bool:
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
		transition_to(PlayerState.JUMP)
		return true
	return false

# =========================
# PHYSICS HELPERS
# =========================

const GRAVITY_FALL := 600.0      # main gravity
const GRAVITY_RISE := 850.0      # lower gravity while going up

func apply_gravity(delta: float) -> void:
	if velocity.y < 0:
		velocity.y += GRAVITY_RISE * delta
	else:
		velocity.y += GRAVITY_FALL * delta

func apply_horizontal_movement(delta: float) -> void:
	# Block prevents horizontal input
	if current_state == PlayerState.BLOCK:
		return
	var dir = Input.get_axis("left", "right")
	if dir != 0:
		velocity.x = move_toward(velocity.x, dir * SPEED, ACCELERATION * delta)
	else:
		var decel = AIR_RESISTANCE if not is_on_floor() else FRICTION
		velocity.x = move_toward(velocity.x, 0, decel * delta)

func apply_friction(delta: float) -> void:
	if current_state == PlayerState.BLOCK:
		return
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

# =========================
# STATE TRANSITIONS
# =========================
func transition_to(new_state: PlayerState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	enter_state(new_state)

func enter_state(state: PlayerState) -> void:
	match state:
		PlayerState.IDLE:
			sprite.play("default")
		PlayerState.RUN:
			sprite.play("run")
		PlayerState.JUMP:
			sprite.play("jump")
		PlayerState.FALL:
			sprite.play("fall")
		PlayerState.ROLL:
			roll_timer = ROLL_DURATION
			sprite.play("roll")
		PlayerState.BLOCK:
			sprite.play("block")
		PlayerState.ATTACK:
			pass

func on_hurt(kb_direction: Vector2, force: float):
	# Don't take knockback if already dead
	if health_component.current_health <= 0:
		return
	
	knockback_velocity = kb_direction * force
	
	# Play hurt effect animation
	if effects_animation_player:
		effects_animation_player.stop()
		effects_animation_player.play("hurt")
	
	is_hurt = true
	print("Player was hurt! Knockback: ", knockback_velocity)
	
