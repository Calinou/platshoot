# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

signal singleplayer_pressed
signal multiplayer_pressed
signal options_pressed

onready var multiplayer_button := $VBoxContainer/Multiplayer as Button


func _ready() -> void:
	# Hide HUD when entering main menu
	Game.hide_hud()

	# Inform the user about multiplayer being disabled in the HTML5 export.
	if OS.has_feature("HTML5"):
		multiplayer_button.disabled = true
		multiplayer_button.hint_tooltip = tr("Multiplayer isn't supported in the HTML5 export.\nDownload a native version of Platshoot to play online!")


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
