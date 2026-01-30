extends Area2D
@export var speed: float = 350.0
@export var damage: int = 5
@export var lifetime: float = 5.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered) 
	
	monitoring = true
	monitorable = false
	
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta):
	if direction == Vector2.ZERO:
		return
	
	position += direction * speed * delta

func set_direction(dir: Vector2):
	direction = dir.normalized()
	
	if has_node("Sprite2D"):
		$Sprite2D.rotation = direction.angle()

func _on_body_entered(body):
	var hurtbox = body.find_child("Hurtbox", true, false)
	if hurtbox and hurtbox.has_method("take_hit"):
		hurtbox.take_hit(damage, global_position)
	elif body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(damage)
	
	queue_free()
