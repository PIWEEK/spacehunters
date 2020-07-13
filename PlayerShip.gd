extends KinematicBody2D


onready var laser := $LaserBeam2D
onready var network = get_node("/root/Network")

var last_position
var speed = 400

puppet var puppet_position = Vector2()
puppet var puppet_direction = Vector2.ZERO
puppet var fire_weapon = false

func _ready() -> void:
    if is_network_master():  
        var camera = Camera2D.new()
        camera.current = true
        self.add_child(camera)
        
func _process(delta: float) -> void:        
    if is_network_master():  
        pass
    else:
        laser.is_casting = fire_weapon
        
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
        
    if get_tree().is_network_server():
        network.update_position(int(name), position)        
    
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
        rset("fire_weapon", laser.is_casting)

func init(nickname, start_position):
    global_position = start_position
