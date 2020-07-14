extends KinematicBody2D

onready var laser := $LaserBeam2D
onready var network = get_node("/root/Network")
var default_speed = 400

var last_direction
var speed = default_speed
var turn_speed = deg2rad(5)
var plasma = preload('res://Projectiles/PlasmaShot.tscn')
var can_fire = true
var fire_rate := 0.2
var charge = false

puppet var puppet_position = Vector2()
puppet var puppet_direction = 0.0
puppet var puppet_global_position = Vector2()
puppet var fire_main_weapon = false
puppet var fire_secondary_weapon = false

func _ready() -> void:
    if is_network_master():  
        var camera = Camera2D.new()
        camera.current = true
        self.add_child(camera)
        
    self.rotation = get_dir()
        
func _process(delta: float) -> void:     
    if charge:
        return
       
    if is_network_master():  
        if Input.is_action_pressed("fire_weapon") && not Input.is_action_pressed("fire_secondary_weapon") && can_fire:
            rpc("plasma_shot")
            can_fire = false
            yield(get_tree().create_timer(fire_rate), 'timeout')
            can_fire = true
            
    elif laser.is_casting != fire_secondary_weapon:
        laser.is_casting = fire_secondary_weapon    
    
func get_dir():
    return self.get_angle_to(get_global_mouse_position())
    
func _physics_process(delta: float) -> void:
    if charge:
        return

    var dir = get_dir()
    var movement = get_movement();
    
    if speed > default_speed:
        speed -= delta * 300

        if speed < default_speed:
            speed = default_speed
    
    if is_network_master():   
        if last_direction != dir:     
            if abs(dir) < turn_speed:
                self.rotation += dir
            else:
                if dir > 0: self.rotation += turn_speed
                if dir < 0: self.rotation -= turn_speed
                
            rset_unreliable("puppet_direction", self.rotation)
            
        
        move_and_collide(movement * speed * delta)
        
        rset("puppet_position", movement * speed * delta)
        rset_unreliable("puppet_global_position", position)
    else:
        self.rotation = puppet_direction
        self.position = puppet_global_position        
        #move_and_collide(puppet_position)
        
    if get_tree().is_network_server():
        var player_id = int(name)
        
        if network.players.has(player_id):
            network.update_position(int(name), position)        
        else:
            queue_free()
    
func get_movement() -> Vector2:
    if speed > default_speed:
        return Vector2(cos(self.rotation), sin(self.rotation))
        
    return Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )

func init_charge():
    charge =  true
    $ParticlesCharge.emitting = true
    yield(get_tree().create_timer(2.8), "timeout")
    $ParticlesBoost.emitting = true    
    charge =  false
    speed = 3000

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action("charge"):
        
        if event.is_action_pressed("charge"):
            init_charge()
        return
    
    if is_network_master():
        if not event.is_action("fire_secondary_weapon"):
            return       
            
        laser.is_casting = event.is_action_pressed("fire_secondary_weapon")
        rset("fire_secondary_weapon", laser.is_casting)

remotesync func plasma_shot():
    var projectile = plasma.instance()
    
    if speed > default_speed:
        projectile.speed = (speed - default_speed) + projectile.default_speed
    
    projectile.global_position = $InitProjectile.global_position
    projectile.direction = Vector2(cos(self.rotation), sin(self.rotation))
    
    $'/root/Main'.add_child(projectile)

func init(nickname, start_position):
    global_position = start_position
