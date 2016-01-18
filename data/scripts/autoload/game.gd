extends Node

onready var hud_scene = preload("res://data/scenes/hud/main.tscn")

func _ready():
	var hud = hud_scene.instance()
	add_child(hud)
	