# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

signal singleplayer_pressed
signal multiplayer_pressed
signal options_pressed

func _ready() -> void:
	# Hide HUD when entering main menu
	Game.hide_hud()


#func _on_join_server_button_pressed() -> void:
#	visible = false
#	Lobby.join_server()
#
#
#func _on_host_server_button_pressed() -> void:
#	visible = false
#	Lobby.start_server()

func _on_singleplayer_pressed() -> void:
	emit_signal("singleplayer_pressed")
	visible = false


func _on_multiplayer_pressed() -> void:
	emit_signal("multiplayer_pressed")
	visible = false


func _on_options_pressed() -> void:
	emit_signal("options_pressed")
	visible = false


func _on_quit_game_pressed() -> void:
	get_tree().quit()
