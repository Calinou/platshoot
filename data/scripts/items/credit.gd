# Copyright (c) 2016 Calinou and contributors
# Licensed under the MIT license, see `LICENSE.md` for more information.

extends Node2D

var picked = false

func _on_Area2D_body_enter(body):
	# Only the player can pick up items
	if body.get_name() == "Player" and not picked:
		# Don't pick up item if ammo >= 100 or if dead
		if Game.status == Game.STATUS_DEAD:
			return

		picked = true
		Game.credits += 250
		Game.items += 1
		get_node("AnimationPlayer").play("Pickup")
		#get_node("AudioStreamPlayer2D").play("pickup")  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func _on_AnimationPlayer_finished():
	queue_free()

