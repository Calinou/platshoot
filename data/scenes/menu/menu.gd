# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

onready var main := $Main as Control
onready var multiplayer_lobby := $MultiplayerLobby as Control


func _ready() -> void:
	if OS.has_feature("Server") or "--dedicated" in OS.get_cmdline_args():
		# "Dedicated" server (run from a non-player client).
		main.visible = false
		multiplayer_lobby.dedicated = true
		multiplayer_lobby.start_server()
		return

	if "--server" in OS.get_cmdline_args():
		# "Listen" server (run from a player client).
		main.visible = false
		multiplayer_lobby.start_server()
		return

	if "--client" in OS.get_cmdline_args():
		main.visible = false
		multiplayer_lobby.join_server("localhost")
		return
