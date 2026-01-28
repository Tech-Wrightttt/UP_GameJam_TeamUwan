extends State

@export var attack_animations: Array[String] = ["attack", "attack1"]  
@export var min_attack_duration := 0.8 
@export var max_attack_duration := 1.5
@export var attack_cooldown := 0.5

var attack_timer := 0.0
var current_attack_duration := 1.0
var is_in_cooldown := false
var current_attack_index := 0
var hitbox_enabled := false  # Track if hitbox is currently active

func enter():
	super()
	boss.set_can_move(false)
	boss.velocity = Vector2.ZERO
	hitbox_enabled = false
	
	if not is_in_cooldown:
		current_attack_index = randi() % attack_animations.size()
		var random_attack = attack_animations[current_attack_index]
		print("Starting attack: ", random_attack)
		
		boss.play_anim(random_attack)
		current_attack_duration = randf_range(min_attack_duration, max_attack_duration)
		attack_timer = 0.0
		
		# Enable hitbox for a brief window (e.g., 0.3 seconds into the attack)
		await get_tree().create_timer(0.3).timeout
		if fsm.current_state == self:  # Still in attack state
			_enable_attack_hitbox()
			hitbox_enabled = true
			# Disable after brief window
			await get_tree().create_timer(0.2).timeout
			if fsm.current_state == self:
				boss.disable_all_hitboxes()
				hitbox_enabled = false
	else:
		boss.play_anim("idle")

func _enable_attack_hitbox():
	if current_attack_index == 0:
		boss.enable_hitbox_attack1()
	elif current_attack_index == 1:
		boss.enable_hitbox_attack2()

func exit():
	super()
	is_in_cooldown = false
	boss.velocity = Vector2.ZERO
	boss.disable_all_hitboxes()
	hitbox_enabled = false

func _physics_process(delta):
	super(delta) 
	attack_timer += delta
	boss.velocity.x = 0

func transition():
	if attack_timer < current_attack_duration:
		return
	
	var distance = boss.direction.length()
	
	if distance > 90:
		print("Player too far, switching to FOLLOW")
		is_in_cooldown = false
		fsm.change_state("follow")
	else:
		if not is_in_cooldown:
			print("Attack finished, starting cooldown")
			is_in_cooldown = true
			attack_timer = 0.0
			current_attack_duration = attack_cooldown
			boss.play_anim("idle")
			boss.disable_all_hitboxes()
		else:
			print("Cooldown finished, performing another attack")
			is_in_cooldown = false
			fsm.change_state("attack")
