extends State

var follow_timer := 0.0
@onready var attack_range = boss.get_node("PlayerDetection")
@export var dist := 100

func enter():
	super()
	boss.play_anim("run")
	boss.set_can_move(true)
	follow_timer = 0.0

func _physics_process(delta):
	super(delta)
	boss.try_jump()
	transition()  # ADD THIS LINE

func transition():
	follow_timer += get_physics_process_delta_time()
	if follow_timer < 0.2:
		return
	
	var distance = boss.direction.length()
	print("Follow - Distance: ", distance, " | Threshold: ", dist)  # Debug
	if distance < dist:
		print("Changing to ATTACK")  # Debug
		fsm.change_state("attack")
