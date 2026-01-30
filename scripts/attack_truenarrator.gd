extends State

@export var attack_animations: Array[String] = []  
@export var attack_duration := 0.5
@export var attack_cooldown := 0.75
@export var dist := 100

var state_timer := 0.0
var is_in_cooldown := false
var current_attack_index := 0

func enter():
	if boss.is_dead:
		return
	
	super()
	boss.set_can_move(false)
	boss.velocity.x = 0
	state_timer = 0.0
	
	if not is_in_cooldown:
		current_attack_index = randi() % attack_animations.size()
		var random_attack = attack_animations[current_attack_index]
		boss.perform_attack(random_attack)
		is_in_cooldown = true
		state_timer = 0.0  # ← Reset timer
	else:
		# Don't play idle here, let the current animation finish
		# boss.play_anim("idle")  # ← Remove or comment out
		pass

func transition():
	if boss.is_dead:
		return
	
	if is_in_cooldown and state_timer < attack_cooldown:
		return  # Still in cooldown
	
	var distance = boss.direction.length()
	
	if distance >= dist:
		is_in_cooldown = false
		fsm.change_state("follow")
	else:
		# Ready for next attack
		is_in_cooldown = false  # ← Reset before changing state
		state_timer = 0.0
		fsm.change_state("attack")

func exit():
	super()
	boss.velocity = Vector2.ZERO

func _physics_process(delta):
	if boss.is_dead:
		return
		
	super(delta) 
	state_timer += delta
	boss.velocity.x = 0
