extends KinematicBody2D

onready var laser := $LaserBeam2D
onready var network = get_node("/root/Network")

var last_direction
var speed = 400
var turn_speed = deg2rad(5)
var plasma = preload('res://Projectiles/PlasmaShot.tscn')
var can_fire = true
var fire_rate := 0.2

puppet var puppet_position = Vector2()
puppet var puppet_direction = Vector2.ZERO
puppet var fire_weapon = false

func _ready() -> void:
    if is_network_master():  
        var camera = Camera2D.new()
        camera.current = true
        self.add_child(camera)
        
    self.rotation = get_dir()
        
func _process(delta: float) -> void:        
    if is_network_master():  
        if Input.is_action_pressed("fire_weapon") && can_fire:
            plasma_shot()
            can_fire = false
            yield(get_tree().create_timer(fire_rate), 'timeout')
            can_fire = true
            
    elif laser.is_casting != fire_weapon:
        laser.is_casting = fire_weapon
    
func get_dir():
    return self.get_angle_to(get_global_mouse_position())
    
func _physics_process(delta: float) -> void:
    var dir = get_dir()
    var movement = get_movement();
    
    if is_network_master():   
        if last_direction != dir:     
            if abs(dir) < turn_speed:
                self.rotation += dir
            else:
                if dir > 0: self.rotation += turn_speed
                if dir < 0: self.rotation -= turn_speed
                
            rset_unreliable("puppet_direction", dir)
            
        move_and_collide(movement * speed * delta)
        rset_unreliable("puppet_position", movement * speed)
    else:
        self.rotation = puppet_direction
        move_and_collide(puppet_position * delta)
        
    if get_tree().is_network_server():
        var player_id = int(name)
        
        if network.players.has(player_id):
            network.update_position(int(name), position)        
        else:
            queue_free()
    
func get_movement() -> Vector2:
    return Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )

func _unhandled_input(event: InputEvent) -> void:
    if is_network_master():
        if not event.is_action("fire_secondary_weapon"):
            return       
            
        laser.is_casting = event.is_action_pressed("fire_secondary_weapon")
        rset("fire_weapon", laser.is_casting)

func plasma_shot():
    var projectile = plasma.instance()
    projectile.global_position = $InitProjectile.global_position
    projectile.direction = Vector2(cos(self.rotation), sin(self.rotation))

    $'/root/Main'.add_child(projectile)

func init(nickname, start_position):
    global_position = start_position
