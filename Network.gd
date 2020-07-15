extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 10

var players = { }
var asteroids = {}
var self_data = { name = '', position = Vector2(360, 180) }
var player_id = 0

signal player_disconnected
signal server_disconnected

func _ready():
    get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
    get_tree().connect('network_peer_connected', self, '_on_player_connected')

func create_server(player_nickname):
    self_data.name = player_nickname
    self_data.position = Vector2(1, 1)
    players[1] = self_data
    var peer = NetworkedMultiplayerENet.new()
    peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
    get_tree().set_network_peer(peer)

func connect_to_server(player_nickname, ip = DEFAULT_IP):
    self_data.name = player_nickname
    get_tree().connect('connected_to_server', self, '_connected_to_server')
    if ip.length() == 0:
        ip = DEFAULT_IP

    var peer = NetworkedMultiplayerENet.new()
    peer.create_client(ip, DEFAULT_PORT)
    get_tree().set_network_peer(peer)

func _connected_to_server():
    var local_player_id = get_tree().get_network_unique_id()
    players[local_player_id] = self_data
    rpc('_send_player_info', local_player_id, self_data)

func _on_player_disconnected(id):
    players.erase(id)

func _on_player_connected(connected_player_id):
    var local_player_id = get_tree().get_network_unique_id()

    if not(get_tree().is_network_server()):
        rpc_id(1, '_request_player_info', local_player_id, connected_player_id)

remote func _request_player_info(request_from_id, player_id):
    if get_tree().is_network_server():
        rpc_id(request_from_id, '_send_player_info', player_id, players[player_id])

remote func _request_players(request_from_id):
    if get_tree().is_network_server():
        for peer_id in players:
            if(peer_id != request_from_id):
                rpc_id(request_from_id, '_send_player_info', peer_id, players[peer_id])

remote func _send_player_info(id, info):
    players[id] = info
    var new_player = load('res://PlayerShip.tscn').instance()
    new_player.name = str(id)
    new_player.set_network_master(id)
    $'/root/Main'.add_child(new_player)
    new_player.init(info.name, info.position)

func update_position(id, position):
    players[id].position = position
    
func erase_asteroid(id):
    asteroids.erase(id)
    
func update_asteroid(id, position, rotation_degrees, scale):
    asteroids[id] = { position = position, rotation_degrees = rotation_degrees, scale = scale }
