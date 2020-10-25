# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node

# Consts for status
const STATUS_ALIVE = 0
const STATUS_DEAD = 1

# Consts for weapons
const WEAPON_FIST = 0
const WEAPON_PISTOL = 1
const WEAPON_CHAINGUN = 2

const WEAPON_MAX = WEAPON_CHAINGUN

# Game stats (maximal)
# TODO: Use them in other scripts
const HEALTH_MAX = 100.0
const ARMOR_MAX = 100.0
const AMMO_MAX = 100

const hud_scene := preload("res://data/scenes/hud/main.tscn")
const background_scene := preload("res://data/scenes/misc/background.tscn")

# Game stats
onready var health := 100.0
onready var armor := 0.0
onready var ammo := 25
onready var weapon := WEAPON_PISTOL
onready var fuel := 100.0

# Level stats
onready var time := 0.0
onready var kills := 0
onready var kills_total := 0
onready var items := 0
onready var items_total := 0

# For menus and respawning
onready var level_to_play := 1

onready var status := STATUS_ALIVE


func _ready() -> void:
	randomize()
	print("Platshoot [0.1.0]")

	var hud = hud_scene.instance()
	add_child(hud)

	var background = background_scene.instance()
	add_child(background)


func _physics_process(_delta: float) -> void:
	# Prevent health from going below 0
	if Game.health <= 0:
		Game.health = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.is_window_fullscreen()

	if event.is_action_pressed("toggle_hud"):
		get_node("/root/Game/HUD/Control").visible = not get_node("/root/Game/HUD/Control").visible


# Makes a number (like 80) into a string like "1:20"
func time_string(game_time: float) -> String:
	return str(floor(game_time / 60)) + ":" + str(int(game_time) % 60).pad_zeros(2)


func get_weapon_name(weap: int) -> String:
	if weap == WEAPON_FIST:
		return tr("Fist")
	elif weap == WEAPON_PISTOL:
		return tr("Pistol")
	elif weap == WEAPON_CHAINGUN:
		return tr("Chaingun")

	return tr("Unknown")


# Hides the HUD (for menu, and the "hide HUD" key)
# The HUD elements are hidden individually because CanvasLayer can't be hidden
func hide_hud() -> void:
	get_node("/root/Game/HUD/Notices").hide()
	get_node("/root/Game/HUD/FPS").hide()
	get_node("/root/Game/HUD/Stats").hide()
	get_node("/root/Game/HUD/Control").hide()


# Shows the HUD (when the player enters game, or uses the "hide HUD" key while
# the HUD is hidden
func show_hud() -> void:
	get_node("/root/Game/HUD/Notices").show()
	get_node("/root/Game/HUD/FPS").show()
	get_node("/root/Game/HUD/Stats").show()
	get_node("/root/Game/HUD/Control").show()
