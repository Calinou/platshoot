# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

signal join_game_pressed(server_address)
signal host_game_pressed
signal back_pressed

@onready var server_address := $VBoxContainer/HBoxContainer/ServerAddress as LineEdit


func _ready() -> void:
	server_address.text = "localhost"


# This method is also connected to the text field's `text_entered` signal,
# so discard its text argument.
func _on_join_game_pressed(_text: String = "") -> void:
	emit_signal("join_game_pressed", server_address.text)
	visible = false


func _on_host_game_pressed() -> void:
	emit_signal("host_game_pressed")
	visible = false


func _on_back_pressed() -> void:
	emit_signal("back_pressed")
	visible = false
