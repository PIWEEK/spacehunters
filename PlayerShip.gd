extends Node2D

onready var laser := $LaserBeam2D
var is_current_player
var last_position

slave var slave_position = Vector2()

func _process(_delta: float) -> void:
    if is_network_master():
        var new_position = get_global_mouse_position()
        
        if last_position != new_position:
            look_at(new_position)
            last_position = new_position
            
            rset_unreliable("slave_position", new_position)
    else:
        look_at(slave_position)         

func _unhandled_input(event: InputEvent) -> void:
    if is_network_master():
        if not event.is_action("fire_weapon"):
            return
        laser.is_casting = event.is_action_pressed("fire_weapon")

func init(nickname, start_position):
    global_position = start_position
