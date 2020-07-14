extends Node2D

onready var global = get_node("/root/Global")

func _ready() -> void:    
    var selfPeerID = get_tree().get_network_unique_id()
    create_player(selfPeerID)         

func create_player(id):
    Network.players[get_tree().get_network_unique_id()] = Network.self_data
    
    var player = preload("res://PlayerShip.tscn").instance()
    player.set_name(str(id))
    player.set_network_master(id)
    var info = Network.self_data
    player.init(info.name, info.position)
    self.add_child(player)        
