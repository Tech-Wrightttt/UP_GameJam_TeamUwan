extends State

func enter():
	super()
	boss.play_anim("run")
	boss.set_can_move(true)

func exit():
	super()
	boss.set_can_move(false)

func transition():
	print(boss.direction.length())
	if boss.direction.length() < 1:
		fsm.change_state("attack")
