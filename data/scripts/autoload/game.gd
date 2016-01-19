extends Node

onready var hud_scene = preload("res://data/scenes/hud/main.tscn")
onready var background_scene = preload("res://data/scenes/misc/background.tscn")

# Consts for status
const STATUS_ALIVE = 0
const STATUS_DEAD = 1

# Consts for weapons
const WEAPON_FIST = 0
const WEAPON_PISTOL = 1
const WEAPON_CHAINGUN = 2

# Game stats
onready var health = 100.0
onready var armor = 0.0
onready var ammo = 25
onready var weapon = WEAPON_PISTOL

# Level stats
onready var time = 0.0
onready var kills = 0
onready var kills_total = 0
onready var items = 0
onready var items_total = 0

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

# Makes a number (like 80) into a string like "1:20"
func time_string(game_time):
	return str(floor(game_time / 60)) + ":" + str(int(game_time) % 60).pad_zeros(2)

func get_weapon_name(weap):
	if weap == WEAPON_FIST:
		return "FIST"
	elif weap == WEAPON_PISTOL:
		return "PISTOL"
	elif weap == WEAPON_CHAINGUN:
		return "CHAINGUN"
		