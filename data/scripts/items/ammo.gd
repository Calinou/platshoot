# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node2D

var picked := false


func _on_Area2D_body_enter(body: Node2D) -> void:
	# Don't pick up item if having full ammo or if dead.
	if Game.ammo >= 100 or Game.status == Game.STATUS_DEAD:
		return

	# Only the player can pick up items.
	if body.name == "Player" and body.is_network_master() and not picked:
		rpc("pickup")
		Game.ammo = int(min(Game.ammo + 15, 100))


func _on_AnimationPlayer_finished(_anim_name: String) -> void:
	queue_free()

remotesync func pickup() -> void:
	picked = true
	$AnimationPlayer.play("Pickup")
	var positional: int = (
			Sound.Type.NON_POSITIONAL if get_tree().get_rpc_sender_id() == get_tree().get_network_unique_id()
			else Sound.Type.POSITIONAL_2D
	)
	Sound.play(positional, self, preload("res://data/sounds/pickup.wav"), 0.0, 1.1)
	# Item counter is intentionally shared across players.
	Game.items += 1
