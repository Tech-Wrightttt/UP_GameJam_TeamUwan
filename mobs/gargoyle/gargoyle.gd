extends CharacterBody2D

# =========================
# MOVEMENT TUNING
# =========================
const SPEED = 120.0 # Slower than player
const ACCELERATION = 800.0
const FRICTION = 1000.0
const GRAVITY_STRENGTH = 980.0

# =========================
# AI TUNING
# =========================
const ATTACK_COOLDOWN = 1.5
const CHASE_MEMORY_TIME = 2.0 # How long to chase after losing sight

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: Node = $HealthComponent # Assumed type based on player script
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox = $Hitbox_Attack1

# =========================
# STATES
# =========================
enum EnemyState {
	IDLE,
	CHASE,
	ATTACK,
	DEATH
}

var current_state: EnemyState = EnemyState.IDLE
var target: CharacterBody2D = null # The Player

# =========================
# TIMERS / LOGIC
# =========================
var attack_cooldown_timer := 0.0
var is_attacking: bool = false
var is_dead: bool = false

func _ready() -> void:
	# Connect Health Signals
	if health_component.has_signal("died"):
		health_component.died.connect(_on_died)
	

	# Connect Animation Signals
	sprite.animation_finished.connect(_on_animation_finished)
	
	# Initial Setup
	disable_hitbox()
	transition_to(EnemyState.IDLE)

# =========================
# MAIN LOOPS
# =========================
func _physics_process(delta: float) -> void:
	if is_dead: 
		apply_gravity(delta)
		move_and_slide()
		return

	update_timers(delta)
	decide_logic()
	update_state(delta)
	move_and_slide()

# =========================
# AI LOGIC
# =========================
func update_timers(delta: float) -> void:
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

func decide_logic() -> void:
	# If we are already attacking or dead, do not change state via logic
	if is_attacking or is_dead:
		return

	# If we have a target
	if target:
		var distance_to_target = global_position.distance_to(target.global_position)
		var x_distance = abs(global_position.x - target.global_position.x)
		
		# Facing Direction
		if target.global_position.x < global_position.x:
			sprite.flip_h = true # Face Left
		else:
			sprite.flip_h = false # Face Right
		
		# Attack Range Logic (approx 50 pixels)
		if x_distance < 50.0 and abs(global_position.y - target.global_position.y) < 50.0:
			if attack_cooldown_timer <= 0:
				transition_to(EnemyState.ATTACK)
			else:
				transition_to(EnemyState.IDLE) # Wait for cooldown
		else:
			transition_to(EnemyState.CHASE)
	else:
		transition_to(EnemyState.IDLE)

# =========================
# STATE MACHINE
# =========================
func update_state(delta: float) -> void:
	match current_state:
		EnemyState.IDLE:
			state_idle(delta)
		EnemyState.CHASE:
			state_chase(delta)
		EnemyState.ATTACK:
			state_attack(delta)
		EnemyState.DEATH:
			pass

func state_idle(delta: float) -> void:
	apply_friction(delta)
	apply_gravity(delta)

func state_chase(delta: float) -> void:
	if target:
		var dir = -1 if sprite.flip_h else 1
		velocity.x = move_toward(velocity.x, dir * SPEED, ACCELERATION * delta)
	else:
		apply_friction(delta)
	
	apply_gravity(delta)

func state_attack(delta: float) -> void:
	# Stop moving while attacking
	apply_friction(delta) 
	apply_gravity(delta)

# =========================
# TRANSITIONS
# =========================
func transition_to(new_state: EnemyState) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	
	match current_state:
		EnemyState.IDLE:
			sprite.play("idle")
		EnemyState.CHASE:
			sprite.play("walk")
		EnemyState.ATTACK:
			start_attack()
		EnemyState.DEATH:
			sprite.play("die")
			disable_hitbox()
			collision_layer = 0 # Disable collision so player walks through

# =========================
# HELPER FUNCTIONS
# =========================
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY_STRENGTH * delta

func apply_friction(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func start_attack() -> void:
	is_attacking = true
	sprite.play("attack")
	# Optional: Delay enabling hitbox to match specific frame of animation
	# For now, we enable immediately or use a CallMethodTrack in AnimationPlayer
	enable_hitbox()

func enable_hitbox() -> void:
	hitbox.monitoring = true

func disable_hitbox() -> void:
	hitbox.monitoring = false

# =========================
# SIGNALS
# =========================
func _on_detection_body_entered(body: Node2D) -> void:
	print("Detection Area saw: ", body.name)
	if body.name == "main_character" or body.is_in_group("player"):
		target = body
		print("Target Acquired! Switching to Chase.")

func _on_detection_body_exited(body: Node2D) -> void:
	if body == target:
		target = null

func _on_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
		disable_hitbox()
		attack_cooldown_timer = ATTACK_COOLDOWN
		transition_to(EnemyState.IDLE)
	
	if sprite.animation == "die":
		# Optional: Fade out or remove body
		await get_tree().create_timer(2.0).timeout
		queue_free()

func _on_died() -> void:
	is_dead = true
	is_attacking = false
	transition_to(EnemyState.DEATH)
