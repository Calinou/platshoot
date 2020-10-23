# Copyright (c) 2016 Calinou and contributors
# Licensed under the MIT license, see `LICENSE.md` for more information.

extends Node2D

const AMMO_COST = 70
const AMMO_PACKAGE = 15

var close_to_shop = false

func _input(event):
	if event.is_action_pressed("use") and close_to_shop:
		if Game.credits >= AMMO_COST and Game.ammo < 100:
			Game.ammo = min(Game.ammo + AMMO_PACKAGE, 100)
			Game.credits = max(0, Game.credits - AMMO_COST)
			#get_node("AudioStreamPlayer2D").play("pickup")  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		# Bought ammo? Re-check if player has non-full ammo supplies, if they do, show a notice
		elif Game.ammo >= 100:
			get_node("/root/Game/HUD").notice("Ammo supplies already full")
		# Bought ammo? Re-check if player has enough ammo or not, if not, show a notice
		else:
			get_node("/root/Game/HUD").notice("Not enough credits to buy ammo")

func _on_Area2D_body_enter(body):
	if body.get_name() == "Player":
		close_to_shop = true
		# Show a message to display availability of ammo according to credits
		if Game.credits >= AMMO_COST and Game.ammo < 100:
			get_node("/root/Game/HUD").notice("Press [b]MOUSE2[/b] or [b]E[/b] to buy " + str(AMMO_PACKAGE) + " ammo (" + str(AMMO_COST) + " credits)")
		elif Game.ammo >= 100:
			get_node("/root/Game/HUD").notice("Ammo supplies already full")
		else:
			get_node("/root/Game/HUD").notice("Not enough credits to buy ammo")

func _on_Area2D_body_exit(body):
	if body.get_name() == "Player":
		close_to_shop = false
		get_node("/root/Game/HUD").clear_notice()

