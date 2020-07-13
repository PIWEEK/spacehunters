extends Node2D

onready var laser := $LaserBeam2D
var is_current_player
var last_position

func _process(_delta: float) -> void:
    
    if is_current_player:
        var new_position = get_global_mouse_position()
        
        if last_position != new_position:
            look_at(new_position)
            last_position = new_position
            
            rpc("move", new_position)

func _unhandled_input(event: InputEvent) -> void:
    if not event.is_action("fire_weapon"):
        return
    laser.is_casting = event.is_action_pressed("fire_weapon")
