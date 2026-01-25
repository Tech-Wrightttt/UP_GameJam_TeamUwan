extends CharacterBody2D

<<<<<<< HEAD
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")

	# Horizontal movement
	var direction := Input.get_axis("left", "right")
	if direction != 0:
=======

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
>>>>>>> c856d79bf02bd9d1de4ce09ca5b7e04fd613662e
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

<<<<<<< HEAD
	# Animation logic
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	else:
		if direction != 0:
			sprite.flip_h = direction < 0  # flip sprite when moving left
			sprite.play("walk")
		else:
			sprite.play("default")  # idle animation

=======
>>>>>>> c856d79bf02bd9d1de4ce09ca5b7e04fd613662e
	move_and_slide()
