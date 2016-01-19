extends Node

onready var hud_scene = preload("res://data/scenes/hud/main.tscn")

# Game stats
onready var health = 100.0
onready var armor = 0.0
onready var ammo = 30

func _ready():
	var hud = hud_scene.instance()
	add_child(hud)
	
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	# Prevent health from going below 0
	if Game.health <= 0:
		Game.health = 0

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())