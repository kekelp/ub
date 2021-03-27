extends Node2D

var characters = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var CHARACTER = preload("res://character/character.tscn")
onready var arena = get_tree().get_nodes_in_group("arena")[0]
var SERVER_PORT = 44200
var SERVER_IP = "127.0.0.1"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = "trying to connect..."
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer


func _connected_ok():
	print("connected ok")
	$Label.text = "connected ok"

func _server_disconnected():
	print("server disconnect")
	$Label.text = "server disconnect"

func _connected_fail():
	print("connected fail")
	$Label.text = "connected fail"


remote func setup_images(characters_data):
	for c in characters_data:
		spawn_image(c)

func spawn_image(c_data):
	var character = CHARACTER.instance()
	self.add_child(character)
	character.set_color(c_data.color)
	character.set_name(c_data.name)
	character.control_mode = character.CONTROL_MODE.network
	var left_x = arena.get_node("spawn-left").global_position.x
	var right_x = arena.get_node("spawn-right").global_position.x
	var y = self.get_parent().get_node("Arena").get_node("spawn-left").global_position.y
	randomize()
	character.global_position = Vector2( rand_range(left_x, right_x)  , y)
	characters.append(character)

func sync_positions(c_pos):
	# check if the sizes match, if not update characters??? 
	# or have it so they always match
	for i in range(0, c_pos.size()):
		characters[i].get_node("hand").global_position = c_pos.hand_pos
		characters[i].get_node("body").global_position = c_pos.body_pos
		
