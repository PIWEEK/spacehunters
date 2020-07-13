extends Node2D

onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:    
    var selfPeerID = get_tree().get_network_unique_id()
    create_player(selfPeerID, true)         

func create_player(id, is_curreent_player):
    var player = preload("res://PlayerShip.tscn").instance()
    player.set_name(str(id))
    player.set_network_master(id)
    player.is_current_player = is_curreent_player
    
    if !global.is_server:
        player.set_position(player.get_position() + Vector2(100, 0))
        
    self.add_child(player)        


