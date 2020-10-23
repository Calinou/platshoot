# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends CanvasLayer

func _physics_process(delta):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	# Inventory
	get_node("Control/HealthProgressBar").set_value(Game.health)
	get_node("Control/ArmorProgressBar").set_value(Game.armor)
	get_node("Control/AmmoProgressBar").set_value(Game.ammo)
	get_node("Control/FuelProgressBar").set_value(Game.fuel)
	get_node("Control/AmmoLabel").set_text(tr(Game.get_weapon_name(Game.weapon)))

	# Stats
	get_node("FPS/FPSLabel").set_text("FPS: " + str(Engine.get_frames_per_second()))
	get_node("Stats/StatsLabel").set_bbcode("[right][b]" + str(Game.time_string(Game.time)) + "\n\n" + tr("KILLS") + "[/b]\n" + str(Game.kills) + " / " + str(Game.kills_total) + "\n\n[b]" + tr("ITEMS") + "[/b]\n" + str(Game.items) + " / " + str(Game.items_total) + "\n\n[b]" + tr("CREDITS") + "[/b]\n" + str(Game.credits) + "[/right]")

# Spawn a notice at center of screen
# Currently used by shops
func notice(bbcode):
	get_node("Notices/NoticesLabel").set_bbcode("[center]" + bbcode + "[/center]")

# Clears the notice by setting empty text to it
func clear_notice():
	get_node("Notices/NoticesLabel").set_bbcode("")
