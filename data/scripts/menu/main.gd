# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control


func _ready():
	# Hide HUD when entering main menu
	Game.hide_hud()


func _on_PlayButton_pressed():
	get_tree().change_scene_to(load("res://data/scenes/levels/%d.tscn" % Game.level_to_play))
	Game.start_server()

func _on_SpinBox_value_changed(value):
	Game.level_to_play = int(value)


# Change the sound volume when the slider value is changed
func _on_VolumeSlider_value_changed(value):
	AudioServer.set_fx_global_volume_scale(float(value))


func _on_join_server_button_pressed() -> void:
	visible = false
	Lobby.join_server()


func _on_host_server_button_pressed() -> void:
	visible = false
	Lobby.start_server()
