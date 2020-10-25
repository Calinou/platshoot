# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Control

signal back_pressed

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

# If `true`, dedicated server mode is enabled. Any client can start the game, and the host won't be a player.
# If `false`, "listen" server mode is used instead. Only the host can start the game, and the host will be a player.
remote var dedicated := false

onready var player_count_label := $VBoxContainer/PlayerCount as Label
onready var start_button := $VBoxContainer/StartGame as Button


func start_server(start_immediately = false) -> void:
	if dedicated:
		print("Starting dedicated server...")
	else:
		if start_immediately:
			print('Starting "listen" server for singleplayer...')
		else:
			print('Starting "listen" server...')

	visible = true
	var peer := NetworkedMultiplayerENet.new()
	peer.compression_mode = NetworkedMultiplayerENet.COMPRESS_ZSTD
	peer.create_server(PORT, 16)
	get_tree().network_peer = peer


	if start_immediately:
		# This is used for singleplayer mode.
		_on_start_pressed()


func join_server(server_address: String) -> void:
	print("Joining multiplayer server...")
	visible = true
	var peer := NetworkedMultiplayerENet.new()
	peer.compression_mode = NetworkedMultiplayerENet.COMPRESS_ZSTD
	peer.create_client(server_address, PORT)
	get_tree().network_peer = peer


func _ready() -> void:
	# Hide the lobby until we request it.
	visible = false

	player_count_label.text = tr("%d players") % player_count

	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func _player_connected(id: int) -> void:
	# Called on both clients and server when a peer connects. Send my info to it.
	if dedicated:
		# Inform clients that we are a dedicated server, so they don't add us
		# as a player when starting the game.
		rset("dedicated", true)

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
	player_count_label.text = tr("%d players") % player_count


remote func pre_configure_game() -> void:
	# Setting up players might take different amounts of time for every peer
	# due to lag, different hardware, or other reasons. To make sure the game
	# will actually start when everyone is ready, pause the game until
	# all players are ready.
	get_tree().paused = true

	# Load world. The world scene's root node name must be "Level".
	var world = load("res://data/scenes/levels/1.tscn").instance()
	$"/root".add_child(world)

	if not (dedicated and get_tree().get_network_unique_id() == NetworkedMultiplayerPeer.TARGET_PEER_SERVER):
		# Load my player.
		var my_player := preload("res://data/scenes/actors/player.tscn").instance()
		my_player.set_name(str(get_tree().get_network_unique_id()))
		my_player.set_network_master(get_tree().get_network_unique_id())
		$"/root/Level/Players".add_child(my_player)

	# Load other players.
	for other_player in player_info:
		if dedicated and other_player == NetworkedMultiplayerPeer.TARGET_PEER_SERVER:
			# Don't add a player for the server.
			continue

		var player := preload("res://data/scenes/actors/player.tscn").instance()
		player.set_name(str(other_player))
		player.set_network_master(other_player)
		$"/root/Level/Players".add_child(player)

	# Tell server that this peer is done pre-configuring.
	# The server can call `get_tree().get_rpc_sender_id()` to find out who said they were done.
	if not get_tree().is_network_server():
		rpc_id(NetworkedMultiplayerPeer.TARGET_PEER_SERVER, "done_preconfiguring")
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
	if (
			get_tree().is_network_server()
			or get_tree().get_rpc_sender_id() == NetworkedMultiplayerPeer.TARGET_PEER_SERVER
	):
		get_tree().paused = false
		visible = false
		# Game starts now!


func _on_start_pressed() -> void:
	start_button.disabled = true
	print("Starting game...")

	for other_player in player_info:
		rpc_id(other_player, "pre_configure_game")

	pre_configure_game()


func _on_back_pressed() -> void:
	emit_signal("back_pressed")
	visible = false

