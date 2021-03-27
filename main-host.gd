extends Node2D

var connected_peers_id = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SERVER_PORT = 44200
const MAX_PLAYERS = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer


func _player_connected(id):
	# setup images of local characters on client
	var characters = get_tree().get_nodes_in_group("character")
	var character_data = []
	for c in characters:
		character_data.append( c.get_character_data() )
	rpc_id(id, "setup_images", character_data)
	connected_peers_id.append(id)
	print("player connected with id ", id)
	
func _player_disconnected(id):
	print("player disconnected")

func _process(delta):
	if connected_peers_id.size() >= 1:
#		for id in connected_peers_id:
		var characters = get_tree().get_nodes_in_group("character")
		var character_positions = []
		for c in characters:
			character_positions.append( c.get_character_position() )
		for c in characters:
			rpc_unreliable("sync_positions", character_positions)
