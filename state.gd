extends Node2D

class_name State

@onready var fsm = get_parent()
@onready var boss = fsm.get_parent() 
@onready var debug = owner.find_child("debug")
@onready var animation_player = fsm.find_child("AnimationPlayer")
@onready var player = fsm.get_parent().find_child("player")

func _ready () :
	set_physics_process(false)

func enter() :
	set_physics_process(true)

func exit() :
	set_physics_process(false)

func transition() :
	pass

func _physics_process(_delta) :
	transition()
	debug.text = name
