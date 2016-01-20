# Copyright (c) 2016 Calinou and contributors
# Licensed under the MIT license, see `LICENSE.md` for more information.

extends Control

func _on_PlayButton_pressed():
	get_tree().change_scene("res://data/scenes/levels/1.tscn")