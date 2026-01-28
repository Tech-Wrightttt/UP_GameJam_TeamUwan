extends CharacterBody2D

# =========================
# MOVEMENT TUNING
# =========================
const SPEED = 300.0
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

# =========================
# READY
# =========================
func _ready() -> void:
	transition_to(PlayerState.IDLE)

# =========================
# MAIN LOOPS
# =========================
func _physics_process(delta: float) -> void:
	update_timers(delta)
	handle_input()
	update_state(delta)
	move_and_slide()

func _process(_delta: float) -> void:
	if current_state != previous_state:
		print(PlayerState.keys()[current_state])
		previous_state = current_state

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
		start_attack("attack1")
		return
	elif Input.is_action_just_pressed("attack2"):
		start_attack("attack2")
		return
	elif Input.is_action_just_pressed("attack3"):
		start_attack("attack3")
		return

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
		elif Input.is_action_pressed("right"):
			sprite.flip_h = false
			last_direction = 1

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
	# Stop sliding
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	apply_gravity(delta)

	if not sprite.is_playing(): # exit when animation finished
		if not is_on_floor():
			transition_to(PlayerState.FALL)
		else:
			var dir = Input.get_axis("left", "right")
			transition_to(PlayerState.RUN if dir != 0 else PlayerState.IDLE)

# =========================
# ACTIONS
# =========================
func start_attack(anim: String) -> void:
	transition_to(PlayerState.ATTACK)
	sprite.play(anim)

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
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

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
