extends Node2D

onready var diameter = get_node("/root/Main/Line2D")
onready var ShieldCharger = get_node("/root/Main/ShieldCharger")
const ITEM_MINIMAP = preload("res://ItemMiniMap.tscn")
var map_scale
const MAP_BORDER = 125
var shield

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var size = ((-diameter.get_point_position(0)) + diameter.get_point_position(1)).x / 2
    var minimap_size = ($Sprite.texture.get_size() * $Sprite.scale).x + MAP_BORDER
    map_scale = size / minimap_size
    
    shield = ITEM_MINIMAP.instance()
    shield.init(0, 'shield')
    shield.position = Vector2(position.x / map_scale, position.y / map_scale)
    $Sprite.add_child(shield)       
        
func _process(delta: float) -> void:
    for player_id in Network.players:
        var item_node = find_item_by_id(player_id)
        var position = Network.players[player_id].position
        
        if item_node:
            item_node.position = Vector2(position.x / map_scale, position.y / map_scale)
        else:
            var item = ITEM_MINIMAP.instance()
            
            if player_id == Network.player_id:
                item.init(player_id, 'player')
            else:
                item.init(player_id, 'enemy')
                
            item.position = Vector2(position.x / map_scale, position.y / map_scale)
            $Sprite.add_child(item)            

    for asteroid_id in Network.asteroids:
        var item_node = find_item_by_id(asteroid_id)
        var position = Network.asteroids[asteroid_id].position
        
        if item_node:
            item_node.position = Vector2(position.x / map_scale, position.y / map_scale)
        else:
            var item = ITEM_MINIMAP.instance()
            item.init(asteroid_id, 'asteroid')
            item.position = Vector2(position.x / map_scale, position.y / map_scale)
            $Sprite.add_child(item)       
        
    shield.position = Vector2(ShieldCharger.position.x / map_scale, ShieldCharger.position.y / map_scale)

func find_item_by_id(id):
    for child in $Sprite.get_children():
        if(child.id == id):
            return child

    return null
