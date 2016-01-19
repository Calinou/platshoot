extends CanvasLayer

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	# Inventory
	get_node("Control/HealthProgressBar").set_value(Game.health)
	get_node("Control/ArmorProgressBar").set_value(Game.armor)
	get_node("Control/AmmoProgressBar").set_value(Game.ammo)
	get_node("Control/AmmoLabel").set_text(tr(Game.get_weapon_name(Game.weapon)))
	
	# Stats
	get_node("FPS/FPSLabel").set_text("FPS: " + str(OS.get_frames_per_second()))
	get_node("Stats/StatsLabel").set_bbcode("[right][b]" + str(Game.time_string(Game.time)) + "\n\n" + tr("KILLS") + "[/b]\n" + str(Game.kills) + " / " + str(Game.kills_total) + "\n\n[b]" + tr("ITEMS") + "[/b]\n" + str(Game.items) + " / " + str(Game.items_total) + "[/right]")