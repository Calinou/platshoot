# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

# The server port to use.
const PORT = 33233

# Player info, associate ID to data
var player_info := {}
# Info we send to other players
var my_info := {
	name = "Johnson Magenta",
	favorite_color = Color8(255, 0, 255),
}
# Players who are done loading scenes and are ready to play.
var players_done := []

var player_count := 1

onready var player_count_label := $VBoxContainer/PlayerCount as Label
onready var start_button := $VBoxContainer/Start as Button


func start_server() -> void:
	print("Starting server...")
	visible = true
	var peer := NetworkedMultiplayerENet.new()
	peer.create_server(PORT, 16)
	get_tree().network_peer = peer


func join_server() -> void:
	print("Starting client...")
	visible = true
	var peer := NetworkedMultiplayerENet.new()
	peer.create_client("localhost", PORT)
	get_tree().network_peer = peer


func _ready() -> void:
	# Hide the lobby until we request it.
	visible = false

	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

	if "--server" in OS.get_cmdline_args():
		# Hide the main menu.
		$"/root/Control".visible = false
		start_server()

	if "--client" in OS.get_cmdline_args():
		# Hide the main menu.
		$"/root/Control".visible = false
		join_server()


func _player_connected(id: int) -> void:
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)


func _player_disconnected(id: int) -> void:
	print("Player disconnected: %d" % id)
	player_info.erase(id) # Erase player from info.


func _connected_ok() -> void:
	print("Connected to server.")


func _server_disconnected() -> void:
	push_error("Disconnected from the server.")


func _connected_fail() -> void:
	push_error("Couldn't connect to the server.")


remote func register_player(info: Dictionary) -> void:
	var id := get_tree().get_rpc_sender_id()
	player_info[id] = info

	# Update the lobby UI here.
	player_count += 1
	player_count_label.text = "%d players" % player_count


remote func pre_configure_game() -> void:
	# Setting up players might take different amounts of time for every peer
	# due to lag, different hardware, or other reasons. To make sure the game
	# will actually start when everyone is ready, pause the game until
	# all players are ready.
	get_tree().paused = true

	var my_peer_id := get_tree().get_network_unique_id()

	# Load world
	var world = load("res://data/scenes/levels/1.tscn").instance()
	$"/root".add_child(world)

	# Load my player
	var my_player := preload("res://data/scenes/actors/player.tscn").instance()
	my_player.set_name(str(my_peer_id))
	my_player.set_network_master(my_peer_id)
	$"/root/Level/Players".add_child(my_player)

	# Load other players
	for p in player_info:
		var player := preload("res://data/scenes/actors/player.tscn").instance()
		player.set_name(str(p))
		player.set_network_master(p)
		$"/root/Level/Players".add_child(player)

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	if not get_tree().is_network_server():
		rpc_id(1, "done_preconfiguring")
	else:
		post_configure_game()


remote func done_preconfiguring() -> void:
	var who := get_tree().get_rpc_sender_id()
	assert(get_tree().is_network_server())
	assert(who in player_info)
	assert(not who in players_done)

	players_done.append(who)

	if players_done.size() == player_info.size():
		# All players are done loading scenes, start!
		rpc("post_configure_game")

	visible = false


remote func post_configure_game() -> void:
	# Only the server is allowed to tell a client to unpause.
	if get_tree().is_network_server() or get_tree().get_rpc_sender_id() == 1:
		get_tree().paused = false
		# Game starts now!


func _on_start_pressed() -> void:
	start_button.disabled = true
	assert(get_tree().is_network_server())
	print("Starting game...")

	for player in player_info:
		rpc_id(player, "pre_configure_game")

	pre_configure_game()
