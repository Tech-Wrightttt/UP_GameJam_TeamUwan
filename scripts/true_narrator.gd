extends CharacterBody2D

@export var uses_sprite := true
@export var move_speed := 200.0
@export var gravity := 980.0
@export var jump_force := -420.0
@onready var floor_ray: RayCast2D = $FloorRay
@onready var wall_ray: RayCast2D = $WallRay
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fsm = $FiniteStateMachine
@onready var player = get_parent().find_child("main_character", true, false)
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox = $Hurtbox
@onready var hitbox_attack1 = $Hitbox_Attack1
@onready var hitbox_attack2 = $Hitbox_Attack2
@export var effects_animation_player: AnimationPlayer
@export var knockback_decay := 6.0
@export var minion_scene: PackedScene
@export var summon_offset := Vector2(48, 0)
@export var bullet_node: PackedScene
@export var projectile_spawn_offset := Vector2(32, -16)

var direction: Vector2 = Vector2.ZERO
var can_move := false
var is_dead := false
var knockback_velocity := Vector2.ZERO
var is_hurt := false

func spawn_minion():
	if not minion_scene:
		return

	var minion = minion_scene.instantiate()
	minion.global_position = global_position + summon_offset
	get_parent().add_child(minion)
	
func shoot():
	if not bullet_node:
		print("ERROR: No bullet_node assigned!")
		return
	
	if not player:
		print("ERROR: No player reference!")
		return

	var projectile = bullet_node.instantiate()
	
	# Adjust spawn position based on flip
	var spawn_offset = projectile_spawn_offset
	if sprite.flip_h:
		spawn_offset.x = -abs(spawn_offset.x)
	else:
		spawn_offset.x = abs(spawn_offset.x)
	
	projectile.global_position = global_position + spawn_offset

	var dir = (player.global_position - global_position).normalized()
	projectile.set_direction(dir)
	
	print("Spawning projectile at: ", projectile.global_position, " targeting: ", player.global_position)

	get_parent().add_child(projectile)
	
func _ready():
	set_physics_process(false)
	health_component.died.connect(_on_enemy_died)
	hitbox_attack1.deactivate()
	hitbox_attack2.deactivate()
	fsm.start()

func on_hurt(kb_direction: Vector2, force: float):
	if is_dead:
		return
	
	knockback_velocity = kb_direction * force
	
	if effects_animation_player:
		effects_animation_player.stop()
		effects_animation_player.play("hurt")
	
	is_hurt = true

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
		
	if GameManager.get_is_player_dead():
		stop_all_enemy_behavior()
		return
		
	direction = player.global_position - global_position
	if direction.x < 0:
		sprite.flip_h = true
		$Hitbox_Attack1/attack_up.position.x = -abs($Hitbox_Attack1/attack_up.position.x)
		$Hitbox_Attack2/attack.position.x = -abs($Hitbox_Attack2/attack.position.x)
		wall_ray.target_position.x = -abs(wall_ray.target_position.x)
		$PlayerDetection/CollisionShape2D.position.x = -abs($PlayerDetection/CollisionShape2D.position.x)
	else:
		sprite.flip_h = false
		$Hitbox_Attack1/attack_up.position.x = abs($Hitbox_Attack1/attack_up.position.x)
		$Hitbox_Attack2/attack.position.x = abs($Hitbox_Attack2/attack.position.x)
		wall_ray.target_position.x = abs(wall_ray.target_position.x)
		$PlayerDetection/CollisionShape2D.position.x = abs($PlayerDetection/CollisionShape2D.position.x)
	
func _physics_process(delta):
	if is_dead:
		set_physics_process(false)
		return
	
	velocity.y += gravity * delta
	
	velocity.y = min(velocity.y, 1000.0)
	
	if knockback_velocity.length() > 1.0:
		velocity.x = knockback_velocity.x
		knockback_velocity.x = lerp(knockback_velocity.x, 0.0, knockback_decay * delta)
		
		if abs(knockback_velocity.x) < 1.0:
			knockback_velocity = Vector2.ZERO
	else:
		knockback_velocity = Vector2.ZERO
		if can_move and direction != Vector2.ZERO:
			velocity.x = direction.normalized().x * move_speed
		else:
			velocity.x = 0
	
	move_and_slide()
	if is_on_floor():
		velocity.y = 0

func _on_enemy_died():
	if is_dead:
		return
	is_dead = true
	
	animation_player.stop(false)
	if effects_animation_player:
		effects_animation_player.stop(false)
	
	hurtbox.monitoring = false
	hurtbox.monitorable = false
	
	hitbox_attack1.deactivate()
	hitbox_attack1.monitorable = false
	hitbox_attack2.deactivate()
	hitbox_attack2.monitorable = false
	
	set_physics_process(false)
	can_move = false
	
	if fsm and fsm.current_state:
		fsm.current_state.exit() 
	fsm.change_state("death")

func stop_all_enemy_behavior():
	if fsm and fsm.current_state:
		fsm.current_state.exit()
		
	can_move = false

	if animation_player:
		animation_player.stop(false)
	if effects_animation_player:
		effects_animation_player.stop(false)

	hitbox_attack1.deactivate()
	hitbox_attack2.deactivate()
	set_physics_process(false)
	set_process(false)
	velocity = Vector2.ZERO

func should_jump() -> bool:
	if not is_on_floor():
		return false
	
	var horizontal_distance = abs(player.global_position.x - global_position.x)
	if horizontal_distance < 50:  
		return false
	
	if wall_ray.is_colliding():
		if player.global_position.y < global_position.y - 50:  
			return true

	if not floor_ray.is_colliding():
		if player.global_position.y < global_position.y - 20:
			return true
	
	return false

func try_jump():
	if should_jump():
		velocity.y = jump_force
		print("Enemy jumped!")

func perform_attack(attack_name: String):
	match attack_name:
		"summon":
			play_anim("summon")
			animation_player.play("summon")

		"ranged_attack":
			play_anim("ranged_attack")
			animation_player.play("ranged_attack")

		_:
			push_warning("Unknown attack: " + attack_name)
