extends Node2D

const TOTAL_CLOCKS := 3

@onready var counter_label: Label = $counter

func _ready():
	#update_counter()
	print("Level Started")

func add_clock():
	GameManager.add_clock()  # Global counter
	#update_counter()

#func update_counter():
	#counter_label.text = str(GameManager.current_clocks) + "/" + str(TOTAL_CLOCKS)
