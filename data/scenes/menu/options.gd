# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

signal control_options_pressed
signal audio_options_pressed
signal video_options_pressed
signal back_pressed


func _on_control_options_pressed() -> void:
	emit_signal("control_options_pressed")
	visible = false


func _on_audio_options_pressed() -> void:
	emit_signal("audio_options_pressed")
	visible = false


func _on_video_options_pressed() -> void:
	emit_signal("video_options_pressed")
	visible = false


func _on_back_pressed() -> void:
	emit_signal("back_pressed")
	visible = false
