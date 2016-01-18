extends Node

onready var hud_scene = preload("res://data/scenes/hud/main.tscn")

# Game stats
onready var health = 100.0
onready var stamina = 100.0
onready var armor = 0.0
onready var ammo = 30

func _ready():
	var hud = hud_scene.instance()
	add_child(hud)
	