# Copyright (c) 2016 Calinou and contributors
# Licensed under the MIT license, see `LICENSE.md` for more information.

extends Node2D

func _on_Area2D_body_enter(body):
	if body.get_name() == "Player":
		get_tree().change_scene("res://data/scenes/levels/" + str(Game.level_to_play + 1) + ".tscn")
		get_node("/root/Level/Player").respawned()

