# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

signal singleplayer_selected
signal multiplayer_selected
signal options_selected

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
	emit_signal("singleplayer_selected")
	visible = false


func _on_multiplayer_pressed() -> void:
	emit_signal("multiplayer_selected")
	visible = false


func _on_options_pressed() -> void:
	emit_signal("options_selected")
	visible = false


func _on_quit_game_pressed() -> void:
	get_tree().quit()
