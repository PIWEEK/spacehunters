extends Node2D

onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:    
    var selfPeerID = get_tree().get_network_unique_id()
    create_player(selfPeerID)         

func create_player(id):
    var player = preload("res://PlayerShip.tscn").instance()
    player.set_name(str(id))
    player.set_network_master(id)
    
    if !global.is_server:
        player.set_position(player.get_position() + Vector2(100, 0))
        
    self.add_child(player)        
