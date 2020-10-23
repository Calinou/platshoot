# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node2D


func _on_Area2D_body_enter(body):
	if body.get_name() == "Player":
		get_tree().change_scene("res://data/scenes/levels/" + str(Game.level_to_play + 1) + ".tscn")
		get_node("/root/Level/Player").respawned()
