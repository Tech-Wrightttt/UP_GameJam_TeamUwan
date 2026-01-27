extends CharacterBody2D

#    ACCELERATION: Higher = snappier movement
#    FRICTION: Higher = faster stopping
#    AIR_RESISTANCE: Lower = more air control
#    COYOTE_TIME: Longer = more forgiving platforming
#    JUMP_BUFFER_TIME: Longer = more responsive jumps

# Movement constants
const SPEED = 300.0
const ACCELERATION = 2000.0
const FRICTION = 1800.0
const AIR_RESISTANCE = 400.0

# Jump constants
const JUMP_VELOCITY = -400.0
const JUMP_CUT_MULTIPLIER = 0.5
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.15

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# State machine
enum State {
	IDLE,
	WALK,
	JUMP,
	FALL,
	ATTACK
}

var current_state: State = State.IDLE
var previous_state: State = State.IDLE

# Timers and tracking
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var last_direction: int = 1

const ATTACK_DURATION = 1.00
var attack_timer: float = 0.0

func _ready() -> void:
	transition_to(State.IDLE)

func _physics_process(delta: float) -> void:
	# Update timers
	update_timers(delta)
	
	# Handle input
	handle_input()
	
	# Update current state
	update_state(delta)
	
	# Apply physics
	move_and_slide()

func _process(_delta: float) -> void:
	if current_state != previous_state:
		print(State.keys()[current_state])
		previous_state = current_state
		
func update_timers(delta: float) -> void:
	coyote_timer -= delta
	jump_buffer_timer -= delta

	if attack_timer > 0:
		attack_timer -= delta
	
	if is_on_floor():
		coyote_timer = COYOTE_TIME

func handle_input() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER
		
	if Input.is_action_just_pressed("attack"):
		if current_state != State.ATTACK:
			transition_to(State.ATTACK)
	
	if Input.is_action_just_pressed("left"):
		sprite.flip_h = true
		last_direction = -1
		
	elif Input.is_action_just_pressed("right"):
		sprite.flip_h = false
		last_direction = 1

func update_state(delta: float) -> void:
	match current_state:
		State.IDLE:
			state_idle(delta)
		State.WALK:
			state_walk(delta)
		State.JUMP:
			state_jump(delta)
		State.FALL:
			state_fall(delta)
		State.ATTACK:
			state_attack(delta)

func state_idle(delta: float) -> void:
	apply_friction(delta)
	apply_gravity(delta)
	
	var direction = Input.get_axis("left", "right")
	
	# Transition checks
	if try_jump():
		return
	
	if not is_on_floor():
		transition_to(State.FALL)
	elif direction != 0:
		transition_to(State.WALK)

func state_walk(delta: float) -> void:
	apply_horizontal_movement(delta)
	apply_gravity(delta)
	
	var direction = Input.get_axis("left", "right")
	
	# Transition checks
	if try_jump():
		return
	
	if not is_on_floor():
		transition_to(State.FALL)
	elif direction == 0:
		transition_to(State.IDLE)

func state_jump(delta: float) -> void:
	apply_horizontal_movement(delta)
	apply_gravity(delta)
	
	# Transition checks
	if velocity.y >= 0:
		transition_to(State.FALL)
	elif is_on_floor():
		var direction = Input.get_axis("left", "right")
		if direction != 0:
			transition_to(State.WALK)
		else:
			transition_to(State.IDLE)

func state_fall(delta: float) -> void:
	apply_horizontal_movement(delta)
	apply_gravity(delta)
	
	# Transition checks
	if try_jump():
		return
	
	if is_on_floor():
		var direction = Input.get_axis("left", "right")
		if direction != 0:
			transition_to(State.WALK)
		else:
			transition_to(State.IDLE)
			
func state_attack(delta: float) -> void:
	# Stop horizontal movement while attacking
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	apply_gravity(delta)

	# Attack finished
	if attack_timer <= 0:
		if not is_on_floor():
			transition_to(State.FALL)
		else:
			var direction = Input.get_axis("left", "right")
			if direction != 0:
				transition_to(State.WALK)
			else:
				transition_to(State.IDLE)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func apply_horizontal_movement(delta: float) -> void:
	var direction = Input.get_axis("left", "right")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		var deceleration = AIR_RESISTANCE if not is_on_floor() else FRICTION
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func apply_friction(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func try_jump() -> bool:
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
		transition_to(State.JUMP)
		return true
	return false


func transition_to(new_state: State) -> void:
	if current_state == new_state:
		return
	
	# Exit current state
	exit_state(current_state)
	
	# Update state
	previous_state = current_state
	current_state = new_state
	
	# Enter new state
	enter_state(new_state)

func enter_state(state: State) -> void:
	match state:
		State.IDLE:
			sprite.play("default")
		State.WALK:
			sprite.play("walk")
		State.JUMP:
			sprite.play("jump")
		State.FALL:
			sprite.play("fall")
		State.ATTACK:
			sprite.play("attack")
			attack_timer = ATTACK_DURATION

func exit_state(state: State) -> void:
	# Clean up when leaving a state (if needed)
	pass
