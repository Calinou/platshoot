extends Control

onready var main := $Main as Control
onready var multiplayer_lobby := $MultiplayerLobby as Control


func _ready() -> void:
	if "--server" in OS.get_cmdline_args():
		main.visible = false
		multiplayer_lobby.start_server()
		# Don't allow using both `--server` and `--client` at the same time.
		return

	if "--client" in OS.get_cmdline_args():
		main.visible = false
		multiplayer_lobby.join_server()
		return
