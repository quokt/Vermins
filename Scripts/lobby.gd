extends Control

const MULTI_SCENE_PATH = "res://Scenes/Multiplayer_v2.tscn"

signal host_connection_found()

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 8910

onready var spell_info = $"../../TeamBuilder/TeamPreview/SpellInfo"
onready var address = $LobbyPanel/Address
onready var host_button = $LobbyPanel/HostButton
onready var join_button = $LobbyPanel/JoinButton
onready var local_ip_button = $LobbyPanel/GetLocalIP
onready var local_ip_label = $LobbyPanel/GetLocalIP/Label
onready var status_ok = $LobbyPanel/StatusOk
onready var status_fail = $LobbyPanel/StatusFail
onready var port_forward_label = $LobbyPanel/PortForward
onready var find_public_ip_button = $LobbyPanel/FindPublicIP

onready var map_selector = get_tree().get_nodes_in_group("map_selector")[0]

remotesync var server_team := {}
remotesync var client_team := {}
var selected_team := {}

remotesync var IDs = {"Server" : 1}

var peer = null

func _ready():
	# Connect all the callbacks related to networking.
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

#### Network callbacks from SceneTree ####

# Callback from SceneTree.
func _player_connected(id):
	if id == 1:
		rset("client_team", selected_team)
	else:
		rset("server_team" , selected_team)
		rset( "IDs", { "Server" : 1, "Client" : id } )



	# Someone connected, start the game!
	if get_tree().is_network_server():
		_set_status("Connection found!", true)
		
		emit_signal("host_connection_found")
		
		yield(map_selector, "map_selected")
		#yield(get_tree().create_timer(4.0), "timeout")
		rpc("start_game", map_selector.selected_map)
	else:
		rset_id(id, "client_team", selected_team)
		#print("Successfully connected to server with team : " , selected_team)
		_set_status("Connection found : waiting for host to select a map", true)


func _player_disconnected(_id):
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")
		


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	"Connected to server"
	rset("client_team", selected_team)
	pass # This function is not needed for this project.


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	_set_status("Couldn't connect", false)

	get_tree().set_network_peer(null) # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)


func _server_disconnected():
	_end_game("Server disconnected")

##### Game creation functions ######

remotesync func start_game(selected_map : String):
	var level = preload(MULTI_SCENE_PATH).instance()
	
	CombatPrinter.singleplayer = false
	
	level.selected_map = selected_map
	
	level.teams = {
		"Server" : server_team ,
		"Client" : client_team
	}
	level.IDs = IDs
	
	# Connect deferred so we can safely erase it from the callback.
	level.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED)
	
	
	var root = get_parent().get_parent().get_parent()
	
	root.visible = false
	get_tree().get_nodes_in_group("spell_info")[0].remove_from_group("spell_info")
	
	#root.call_deferred("queue_free")
	
	get_tree().get_root().add_child(level)
#	print("start_game function ended")




func _end_game(with_error = ""):
	if has_node("/root/Level"):
		# Erase immediately, otherwise network might show
		# errors (this is why we connected deferred above).
		get_node("/root/Level").free()
		var root = get_parent().get_parent().get_parent()
		root.get_node("Camera2D").make_current()
		spell_info.add_to_group("spell_info")
		
		root.move_camera(root.camera_positions["base"])
		root.current = root.SUB.BASE
		
		yield(get_tree().create_timer(0.5),"timeout")
		
		root.show()
#		get_tree().get_nodes_in_group("camera")[0].current = true

	get_tree().set_network_peer(null) # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)

	_set_status(with_error, false)


func _set_status(text, isok):
	port_forward_label.visible = text == ""
	find_public_ip_button.visible = text == ""
	# Simple way to show status.
	if isok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)


func _on_host_pressed():
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_NONE)
	var err = peer.create_server(DEFAULT_PORT, 1) # Maximum of 1 peer, since it's a 2-player game.
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.",false)
		return
		
	if selected_team.empty():
		_set_status("Can't start, team is empty.", false)
		return
	
	get_tree().set_network_peer(peer)
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	
	server_team = selected_team
	
	_set_status("Waiting for player...", true)

	# Only show hosting instructions when relevant.
	#port_forward_label.visible = true
	#find_public_ip_button.visible = true


func _on_join_pressed():
	var ip = address.get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid", false)
		return
		
	if selected_team.empty():
		_set_status("Can't start, team is empty.", false)
		return
	
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_NONE)
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
	client_team = selected_team
	_set_status("Connecting...", true)


remote func get_team():
	return selected_team


func _on_find_public_ip_pressed():
	OS.shell_open("https://icanhazip.com/")


func _on_GetLocalIP_pressed():
	var ip_adress : String

	if OS.has_feature("Windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	
	local_ip_label.text = ip_adress
