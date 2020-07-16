extends Label

func report_death(attacker, destroyed): 
    text = Network.players[attacker].name + ' has killed ' + Network.players[destroyed].name
    yield(get_tree().create_timer(5), 'timeout')
    text = ""
