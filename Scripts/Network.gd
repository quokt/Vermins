extends Node

signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

const SERVER_PORT := 10567
const MAX_CLIENTS := 2

const SERVER_IP := "192.168.1.1"

var server_team : Dictionary = {}
var server_team_name: String

var client_team : Dictionary = {}
var client_team_name : String

var teams : Dictionary = {
	server_team_name : server_team ,
	client_team_name : client_team_name
}
var players := {}


# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", client_team_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			#end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	print("Connected !")
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	#end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	print(id)
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")






func host_game(team_name : String, team : Dictionary):
	server_team_name = team_name
	server_team = team
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(peer)
	print()
	

func join_game(ip, team_name : String, team : Dictionary):
	client_team_name = team_name
	client_team = team
	
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client(ip, SERVER_PORT)
	print(error)
	get_tree().set_network_peer(peer)


func host_start_game():
	assert(get_tree().is_network_server())
	
	var level = load("res://Scenes/Level.tscn").instance()
	
	level.is_multiplayer = true
	level.teams = teams
	
	get_tree().get_root().get_node("Lobby").hide()
	get_tree().get_root().add_child(level)

func get_team_name():
	if get_tree().is_network_server():
		return server_team_name
	else:
		return client_team_name
	
	

puppet func client_start_game():
	pass

