# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

signal join_game_pressed
signal host_game_pressed
signal back_pressed


func _on_join_game_pressed() -> void:
	emit_signal("join_game_pressed")
	visible = false


func _on_host_game_pressed() -> void:
	emit_signal("host_game_pressed")
	visible = false


func _on_back_pressed() -> void:
	emit_signal("back_pressed")
	visible = false


