extends Node

onready var hud_scene = preload("res://data/scenes/hud/main.tscn")
onready var background_scene = preload("res://data/scenes/misc/background.tscn")

const STATUS_ALIVE = 0
const STATUS_DEAD = 1

# Game stats
onready var health = 100.0
onready var armor = 0.0
onready var ammo = 30

onready var status = STATUS_ALIVE

func _ready():
	print("Platshoot [0.0.1]")

	var hud = hud_scene.instance()
	add_child(hud)
	
	var background = background_scene.instance()
	add_child(background)
	
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	# Prevent health from going below 0
	if Game.health <= 0:
		Game.health = 0

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())