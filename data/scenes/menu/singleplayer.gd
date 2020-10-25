# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

signal new_game_pressed
signal load_game_pressed
signal back_pressed


func _on_back_pressed() -> void:
	emit_signal("back_pressed")
	visible = false


func _on_new_game_pressed() -> void:
	emit_signal("new_game_pressed")
	visible = false


func _on_load_game_pressed() -> void:
	push_error("Loading game isn't implemented yet.")
	emit_signal("load_game_pressed")
	visible = false
