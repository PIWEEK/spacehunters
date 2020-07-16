extends Node2D

func _process(delta: float) -> void:
    for player_id in Network.players:
        var item = find_item_by_id('name-' + str(player_id))
        
        if !item:
            var name = Label.new()
            var player_num = Network.players[player_id].num
            name.name = 'name-' + str(player_id)
            name.size_flags_horizontal = true
            name.text = Network.players[player_id].name
            name.add_color_override("font_color", Global.colors[player_num])
            
            $GridContainer.add_child(name)
            
            var kills = Label.new()
            kills.name = 'kills-' + str(player_id)
            kills.size_flags_horizontal = true
            kills.text = str(0)
            kills.add_color_override("font_color", Global.colors[player_num])
            
            $GridContainer.add_child(kills)
            
            var deaths = Label.new()
            deaths.name = 'deaths-' + str(player_id)
            deaths.size_flags_horizontal = true
            deaths.text = str(0)
            deaths.add_color_override("font_color", Global.colors[player_num])
            $GridContainer.add_child(deaths)                        
        else:
            pass

func find_item_by_id(id):
    for child in $GridContainer.get_children():
        if child.name == id:
            return child

    return null

func update_table(attacker, destroyed): 
    var kills = find_item_by_id('kills-' + str(attacker))
    var count_kills = int(kills.text)
    
    kills.text = str(count_kills + 1)
    
    var deaths = find_item_by_id('deaths-' + str(destroyed))
    var count_deaths = int(deaths.text)
    
    deaths.text = str(count_deaths + 1)    
