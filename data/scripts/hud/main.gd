# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends CanvasLayer

onready var notices_animation_player := $Notices/AnimationPlayer as AnimationPlayer
onready var notices_label := $Notices/NoticesLabel as RichTextLabel

enum BuiltinNoticeType {
	PLAYER_DEATH,
}

func _physics_process(_delta: float) -> void:
	$"Control/HealthProgressBar".value = Game.health
	$"Control/ArmorProgressBar".value = Game.armor
	$"Control/AmmoProgressBar".value = Game.ammo
	$"Control/FuelProgressBar".value = Game.fuel
	$"Control/AmmoLabel".text = Game.get_weapon_name(Game.weapon)
	$"FPS/FPSLabel".text = "FPS: %d" % Engine.get_frames_per_second()
	$"Stats/StatsLabel".bbcode_text = "[right][b]" + str(Game.time_string(Game.time)) + "\n\n" + tr("Kills") + "[/b]\n" + str(Game.kills) + " / " + str(Game.kills_total) + "\n\n[b]" + tr("Items") + "[/b]\n" + str(Game.items) + " / " + str(Game.items_total) + "[/right]"


# Spawns a notice at the center of the screen.
func notice(bbcode: String) -> void:
	notices_label.bbcode_text = "[center]" + bbcode + "[/center]"
	notices_animation_player.play("fade")

# Spawns a predefined notice at center of screen.
# Use this method in RPCs to prevent arbitrary notices from appearing on screen
# from a modified client.
remotesync func builtin_notice(type: int) -> void:
	match type:
		BuiltinNoticeType.PLAYER_DEATH:
			if get_tree().get_rpc_sender_id() == get_tree().get_network_unique_id():
				notice("You died.")
			else:
				notice("Another player died.")


# Clears the existing notice.
func clear_notice() -> void:
	notices_label.bbcode_text = ""
