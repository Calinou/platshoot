# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node2D

var picked := false


func _on_Area2D_body_enter(body: Node2D) -> void:
	# Only the player can pick up items
	if body.get_name() == "Player" and not picked:
		# Don't pick up item if ammo >= 100 or if dead
		if Game.status == Game.STATUS_DEAD:
			return

		picked = true
		Game.credits += 250
		Game.items += 1
		get_node("AnimationPlayer").play("Pickup")
		Sound.play(Sound.Type.NON_POSITIONAL, self, preload("res://data/sounds/pickup.wav"), 0.0, 1.1)


func _on_AnimationPlayer_finished() -> void:
	queue_free()
