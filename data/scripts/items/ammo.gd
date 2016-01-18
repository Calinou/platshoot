extends Node2D

var picked = false

func _on_Area2D_body_enter(body):
	# Only the player can pick up items
	if body.get_name() == "Player" and not picked:
		picked = true
		Game.ammo += 30
		hide()
		get_node("SamplePlayer2D").play("pickup")
