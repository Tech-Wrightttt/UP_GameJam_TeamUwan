extends State

var follow_timer := 0.0
@onready var attack_range = boss.get_node("PlayerDetection")
@export var dist := 100

func enter():
	super()
	boss.play_anim("attack")

func _physics_process(delta):
	super(delta)
	transition()  # ADD THIS LINE

func transition():
	fsm.change_state("attack")
