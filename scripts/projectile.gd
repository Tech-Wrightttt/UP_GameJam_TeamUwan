extends Area2D

@export var speed: float = 350.0
@export var damage: int = 15
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.ZERO

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)
	
	# Set up collision layers/masks
	collision_layer = 64  # Layer 7 (Enemy projectile)
	collision_mask = 4    # Mask 2 (Player body)
	
	monitoring = true
	monitorable = false
	
	print("Projectile spawned at: ", global_position, " direction: ", direction)
	
	# Safety cleanup
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	if direction == Vector2.ZERO:
		return
	
	position += direction.normalized() * speed * delta

func set_direction(dir: Vector2):
	direction = dir
	print("Projectile direction set to: ", dir)
	
	# Rotate sprite to face direction
	if has_node("Sprite2D"):
		$Sprite2D.rotation = dir.angle()

func _on_body_entered(body):
	print("Projectile hit: ", body.name)
	
	# Check for HealthComponent
	if body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(damage)
		print("Dealt ", damage, " damage to ", body.name)
	
	queue_free()
