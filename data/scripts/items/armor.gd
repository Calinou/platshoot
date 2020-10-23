# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node2D

var picked = false


func _on_Area2D_body_enter(body):
	# Only the player can pick up items
	if body.get_name() == "Player" and not picked:
		# Don't pick up item if armor >= 100 or if dead
		if Game.armor >= 100 or Game.status == Game.STATUS_DEAD:
			return

		picked = true
		Game.armor = min(Game.armor + 25, 100)
		Game.items += 1
		get_node("AnimationPlayer").play("Pickup")
		Sound.play(Sound.Type.NON_POSITIONAL, self, preload("res://data/sounds/pickup.wav"), 0.0, 1.1)


func _on_AnimationPlayer_finished():
	queue_free()
