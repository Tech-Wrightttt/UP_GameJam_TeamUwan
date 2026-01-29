extends State

@export var attack_animations: Array[String] = ["attack1", "attack2"]  
@export var attack_duration := 1.2
@export var attack_cooldown := 0.8

var state_timer := 0.0
var is_in_cooldown := false
var current_attack_index := 0

func enter():
	if boss.is_dead:
		return
	
	super()
	boss.set_can_move(false)
	boss.velocity = Vector2.ZERO
	state_timer = 0.0
	
	if not is_in_cooldown:
		current_attack_index = randi() % attack_animations.size()
		var random_attack = attack_animations[current_attack_index]
		print("Starting attack: ", random_attack)
		boss.play_anim(random_attack)
		boss.animation_player.play(random_attack)
	else:
		boss.play_anim("idle")

func exit():
	super()
	boss.velocity = Vector2.ZERO
	boss.hitbox_attack1.deactivate()
	boss.hitbox_attack2.deactivate()

func _physics_process(delta):
	if boss.is_dead:
		return
		
	super(delta) 
	state_timer += delta
	boss.velocity.x = 0

func transition():
	if boss.is_dead:
		return
	
	if not is_in_cooldown and state_timer < attack_duration:
		return
	
	if is_in_cooldown and state_timer < attack_cooldown:
		return
	
	var distance = boss.direction.length()
	
	if not is_in_cooldown:
		if distance > 90:
			is_in_cooldown = false
			fsm.change_state("follow")
		else:
			is_in_cooldown = true
			state_timer = 0.0
			boss.play_anim("idle")
	else:
		if distance > 90:
			is_in_cooldown = false
			fsm.change_state("follow")
		else:
			is_in_cooldown = false
			fsm.change_state("attack")
