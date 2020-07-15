extends KinematicBody2D

const HYPERJUMP_TRAIL_ACTIVE = true

onready var laser := $LaserBeam2D
onready var network = get_node("/root/Network")
onready var shield_node := $Shield
onready var RESPAWAN = $'/root/Main/CanvasLayer/Respawn'
onready var Trail := $Trail2D

var default_speed = 400
var shake_amount = 6.0
var has_boost = false

var last_direction
var speed = default_speed
var turn_speed = deg2rad(5)
var plasma = preload('res://Projectiles/PlasmaShot.tscn')
var explosion = preload('res://Explosion/Explosion.tscn')
var can_fire = true
var fire_rate := 0.2
var charge = false
var camera
var boost_speed = 1500
var hull := 300
var shield := 100
var die = false

puppet var puppet_position = Vector2()
puppet var puppet_direction = 0.0
puppet var puppet_global_position = Vector2()

func _ready() -> void:
    if is_network_master():
        Network.player_id = int(name)
        camera = Camera2D.new()
        camera.current = true

        self.add_child(camera)

    self.rotation = get_dir()

    # Input.set_mouse_mode((Input.MOUSE_MODE_HIDDEN))

# todos
remote func test1():
    print('test1 - remote')

# el dueño de esta instancia
master func test2():
    print('test2 - master')

# el resto de jugadores
puppet func test3():
    print('test3 - puppet')

func _process(delta: float) -> void:
    if Input.is_action_pressed("charge"):
        $Hyperjump.play()
        
    if charge || die:
        return
        
    if Input.is_action_just_pressed("fire_weapon"):
        $Weapon1Sound.play()
    elif Input.is_action_just_pressed("fire_secondary_weapon"):
        $Weapon2Sound.play()
    elif Input.is_action_just_released("fire_secondary_weapon"):
        $Weapon2Sound.stop()

    if is_network_master():
        if Input.is_action_pressed("fire_weapon") && not Input.is_action_pressed("fire_secondary_weapon") && can_fire:
            rpc("plasma_shot", {
                rotation = rotation,
                position = position
            })
            can_fire = false
            yield(get_tree().create_timer(fire_rate), 'timeout')
            can_fire = true

    if Input.is_action_just_pressed("fire_weapon"):
        $Weapon1Sound.play()
    elif Input.is_action_just_pressed("fire_secondary_weapon"):
        $Weapon2Sound.play()

func get_dir():
    return self.get_angle_to(get_global_mouse_position())

func _physics_process(delta: float) -> void:
    if charge || die:
        return

    var dir = get_dir()
    var movement = get_movement();

    if is_network_master():
        if _high_speed():
            if speed > boost_speed - 500:
                camera.set_offset(Vector2(
                    rand_range(-1.0, 1.0) * shake_amount,
                    rand_range(-1.0, 1.0) * shake_amount
                ))

            var new_speed = speed - delta * 300

            if new_speed < default_speed:
                new_speed = default_speed
                
            speed = new_speed
            
            if not self._high_speed():
                rpc('sync_speed', speed)
                
        if last_direction != dir:
            if abs(dir) < turn_speed:
                self.rotation += dir
            else:
                if dir > 0: self.rotation += turn_speed
                if dir < 0: self.rotation -= turn_speed

            rset_unreliable("puppet_direction", self.rotation)

        move_and_collide(movement * speed * delta)

        # rset("puppet_position", movement * speed * delta)
        rset_unreliable("puppet_global_position", position)
    else:
        self.rotation = puppet_direction
        self.position = puppet_global_position
        #move_and_collide(puppet_position)

    var player_id = int(name)

    if network.players.has(player_id):
        network.update_position(int(name), position)
    else:
        queue_free()

    # cancel high speed & if uncommented sync with sound
    # if Input.get_action_strength("ui_down") && _high_speed():
    #    speed = default_speed
    #    rpc('sync_speed', speed)

func get_movement() -> Vector2:
    if(_high_speed()):
        return Vector2(cos(self.rotation), sin(self.rotation))

    return Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )
    
# called to cancel high speed in other players
puppet func sync_speed(new_speed):
    speed = new_speed

remotesync func init_charge(data):
    if not is_network_master():
        self.rotation = data.rotation
        self.position = data.position

    charge =  true
    $ParticlesCharge.emitting = true
    yield(get_tree().create_timer(2.5), "timeout")
    $ParticlesBoost.emitting = true
    charge =  false

    yield(get_tree().create_timer(0.3), "timeout")
    speed = boost_speed

func _unhandled_input(event: InputEvent) -> void:
    if is_network_master():
        if event.is_action("charge"):
            if event.is_action_pressed("charge"):
                rpc("init_charge", {
                    rotation = rotation,
                    position = position
                })
            return

        if not event.is_action("fire_secondary_weapon"):
            return

        rpc("fire_secondary_weapon", {
            plasma = event.is_action_pressed("fire_secondary_weapon"),
            rotation = rotation,
            position = position
        })

remotesync func fire_secondary_weapon(data):
    laser.is_casting = data.plasma

    if not is_network_master():
        self.rotation = data.rotation
        self.position = data.position

remotesync func plasma_shot(data):
    if not is_network_master():
        self.rotation = data.rotation
        self.position = data.position

    var projectile = plasma.instance()

    if _high_speed():
        projectile.speed = (speed - default_speed) + projectile.default_speed

    projectile.global_position = $InitProjectile.global_position
    projectile.direction = Vector2(cos(self.rotation), sin(self.rotation))

    $'/root/Main'.add_child(projectile)

func init(nickname, start_position):
    global_position = start_position

func _high_speed():
    return speed > default_speed

func _on_ShipTrail_timeout():
    if (_high_speed() and HYPERJUMP_TRAIL_ACTIVE):
        var move_vector = get_movement()
        if (move_vector.x != 0 || move_vector.y != 0):
            # first make a copy of ghost object
            var ghost = preload("res://GhostTrail.tscn").instance()
            # give the ghost a parent
            get_parent().add_child(ghost)
            ghost.position = position
            var _scale = Vector2(.7, .7)
            ghost.set_scale(_scale)
            ghost.modulate.a = 0.5
            var dir = ghost.get_angle_to( get_global_mouse_position())+90 # TODO: fix
            ghost.rotation += dir

func damage(amount):
    var ui = $'/root/Main/CanvasLayer/ShieldHullBar'

    if shield > 0:
        shield = shield - amount

        if self.is_network_master():
            ui._on_damage_shield(shield)

    if shield <= 0 && hull > 0:
        shield_node.visible = false

        if shield < 0:
            hull = hull + shield
            shield = 0
        else:
            hull = hull - amount

        if self.is_network_master():
            ui._on_damage_hull(hull)

    if hull <= 0 && !die:
        die = true
        var explosion_instance = explosion.instance()
        self.add_child(explosion_instance)
        $Sprite.visible = false
        $CollisionShape2D.disabled = true
        
        Trail.is_emitting = false
        yield(get_tree().create_timer(2), 'timeout')
        if is_network_master():
            RESPAWAN.init()
        yield(get_tree().create_timer(RESPAWAN.init_time), 'timeout')
        
        global_position.x = Global._random_between(-2000, 2000)
        global_position.y = Global._random_between(-2000, 2000)
            
        $Sprite.visible = true
        $CollisionShape2D.disabled = false   
        die = false   
        hull = 300
        shield = 100
        
        ui._on_damage_shield(shield)
        ui._on_damage_hull(hull)
        shield_node.visible = true
        self.remove_child(explosion_instance)
        
        yield(get_tree().create_timer(1), 'timeout')
        Trail.is_emitting = true      
        
        
        
