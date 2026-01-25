extends CharacterBody2D

<<<<<<< Updated upstream
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
=======
const SPEED := 300.0
const JUMP_VELOCITY := -400.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

var was_on_floor := false
>>>>>>> Stashed changes

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

<<<<<<< Updated upstream
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
=======
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
>>>>>>> Stashed changes
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")

<<<<<<< Updated upstream
	# Horizontal movement
	var direction := Input.get_axis("left", "right")
=======
	var direction := Input.get_axis("ui_left", "ui_right")
>>>>>>> Stashed changes
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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

	move_and_slide()

	update_animation(direction)

	was_on_floor = is_on_floor()


func update_animation(direction):
	if not is_on_floor():
		if velocity.y < 0:
			safe_play("jump")
		else:
			safe_play("fall")
		return


	if direction != 0:
		safe_play("walk")
	else:
		safe_play("idle")


func safe_play(name: String):
	if anim.current_animation != name:
		anim.play(name)
