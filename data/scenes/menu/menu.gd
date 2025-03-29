# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends CanvasLayer

# If `true`, the player is in the main menu.
# If `false`, the player is in the in-game menu (pause menu).
var in_main_menu := true

@onready var menus := $Menus as Control
@onready var main := $Menus/Main as Control
@onready var multiplayer_lobby := $Menus/MultiplayerLobby as Control


func _ready() -> void:
	if OS.has_feature("Server") or "--dedicated" in OS.get_cmdline_args():
		# "Dedicated" server (run from a non-player client).
		main.visible = false
		multiplayer_lobby.dedicated = true
		multiplayer_lobby.start_server()
		return

	if "--server" in OS.get_cmdline_args():
		# "Listen" server (run from a player client).
		main.visible = false
		multiplayer_lobby.start_server()
		return

	if "--client" in OS.get_cmdline_args():
		main.visible = false
		multiplayer_lobby.join_server("localhost")
		return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause_menu"):
		if menus.visible:
			hide_menu()
		else:
			show_menu()

# Hide the main/pause menu and restore the initial state.
func hide_menu() -> void:
	if menus.visible:
		menus.visible = false

		# Restore initial menu state so we can't display several menus at once.
		for menu in get_tree().get_nodes_in_group("menu"):
			menu.visible = false

		# Hide the mouse cursor.
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		Input.set_custom_mouse_cursor(null)
		Input.set_custom_mouse_cursor(preload("res://data/textures/transparent.png"))


# Shows the main/pause menu.
func show_menu() -> void:
	if not menus.visible:
		menus.visible = true
		main.visible = true
		# Restore the mouse cursor.
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(null)


# Called by menu buttons when starting a new game.
func _game_started() -> void:
	hide_menu()
	in_main_menu = false
