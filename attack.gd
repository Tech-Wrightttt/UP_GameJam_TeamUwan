extends State

@export var attack_animations: Array[String] = ["attack", "attack_up"]  
@export var attack_duration = [0.75, 1.5]
@export var attack_cooldown := 0.8

var attack_timer := 0.0
var current_attack_duration := 1.0
var is_in_cooldown := false

func enter():
	super()
	
	if not is_in_cooldown:
		var random_attack = attack_animations.pick_random()
		boss.play_anim(random_attack)
		current_attack_duration = attack_duration.pick_random()
		boss.set_can_move(false)
		attack_timer = 0.0
	else:
		boss.play_anim("idle")
		boss.set_can_move(false)

func exit():
	super()
	is_in_cooldown = false

func _physics_process(delta):
	super(delta) 
	attack_timer += delta
	boss.velocity.x = 0

func transition():
	if attack_timer < current_attack_duration:
		return
	
	var distance = boss.direction.length()

	if distance > 80:
		is_in_cooldown = false
		fsm.change_state("follow")
	else:
		if not is_in_cooldown:
			is_in_cooldown = true
			attack_timer = 0.0
			current_attack_duration = attack_cooldown
			boss.play_anim("idle") 
		else:
			is_in_cooldown = false
			enter() 
