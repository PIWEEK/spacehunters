extends KinematicBody2D


onready var laser := $LaserBeam2D
var last_position
var speed = 400

slave var puppet_position = Vector2()
slave var puppet_direction = Vector2.ZERO
           
func _physics_process(delta: float) -> void:
    var new_position = get_global_mouse_position()
    var movement = get_movement();
    
    if is_network_master():        
        if last_position != new_position:
            look_at(new_position)
            last_position = new_position
            
            rset_unreliable("puppet_direction", new_position)
            
        move_and_collide(movement * speed * delta)
        rset_unreliable("puppet_position", movement * speed)
    else:
        look_at(puppet_direction) 
        move_and_collide(puppet_position * delta)
    
func get_movement() -> Vector2:
    return Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )

func _unhandled_input(event: InputEvent) -> void:
    if is_network_master():
        if not event.is_action("fire_weapon"):
            return
        laser.is_casting = event.is_action_pressed("fire_weapon")

func init(nickname, start_position):
    global_position = start_position
