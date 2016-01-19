extends CanvasLayer

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	get_node("Control/HealthProgressBar").set_value(Game.health)
	get_node("Control/ArmorProgressBar").set_value(Game.armor)
	get_node("Control/AmmoProgressBar").set_value(Game.ammo)