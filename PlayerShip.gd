extends KinematicBody2D

const HYPERJUMP_TRAIL_ACTIVE = true

onready var laser := $LaserBeam2D
onready var network = get_node("/root/Network")
onready var shield_node := $Shield
onready var RESPAWAN = $'/root/Main/CanvasLayer/Respawn'
onready var Trail := $Trail2D
onready var Stats = $'/root/Main/CanvasLayer/Players'
onready var Wall = $'/root/Main/CanvasLayer/Wall'
onready var ui = $'/root/Main/CanvasLayer/ShieldHullBar'
var ghost_trail = preload("res://GhostTrail.tscn")
var weapon1_sound_file = preload('res://Assets/Sounds/Weapon Shot Blaster-06.wav')
var default_speed = 500
var shake_amount = 6.0
var has_boost = false

var color;
var last_direction
var speed = default_speed
var turn_speed = deg2rad(10)
var plasma = preload('res://Projectiles/PlasmaShot.tscn')
var explosion = preload('res://Explosion/Explosion.tscn')
var can_fire = true
var fire_rate := 0.10
var charge = false
var boost_speed = 1800
var hull = Global.PLAYER_HULL
var shield = Global.PLAYER_SHIELD
var die = false
var explosion_instance
var ghost


puppet var puppet_position = Vector2()
puppet var puppet_direction = 0.0
puppet var puppet_global_position = Vector2()

var charge_shield_timer
var enable_charge_shield = false

func _ready() -> void:
    if is_network_master():
        Network.player_id = int(name)
    else:
        self.remove_child($PlayerCamera)

    self.rotation = get_dir()

    laser.player_owner = int(self.name)

    if is_network_master():
        var timer = Timer.new()
        add_child(timer)
        timer.connect("timeout", self, "_charge_shield")
        timer.set_wait_time(0.2)
        timer.set_one_shot(false)
        timer.start()

func _init_charge_shield():
    enable_charge_shield = true

func _charge_shield():
    if enable_charge_shield && shield < Global.PLAYER_SHIELD:
        if shield <= 0:
            shield_node.visible = true
            rpc("remote_shield", shield + 2)
        
        shield += 2
        if shield > Global.PLAYER_SHIELD:
            shield = Global.PLAYER_SHIELD

        # print(shield)
        ui._on_damage_shield(shield, Tween.TRANS_LINEAR)

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
    if charge || die:
        return

    if is_network_master():
        if Input.is_action_pressed("fire_weapon") && not Input.is_action_pressed("fire_secondary_weapon") && can_fire:
            rpc("plasma_shot", {
                rotation = rotation,
                position = position,
            })
            can_fire = false
            yield(get_tree().create_timer(fire_rate), 'timeout')
            can_fire = true

func weapon1_sound():
    var audio_stream = AudioStreamPlayer2D.new()
    audio_stream.stream = weapon1_sound_file
    audio_stream.volume_db = -15
    audio_stream.max_distance = 1500

    self.add_child(audio_stream)

    audio_stream.connect("finished", self, "audio_weapon1_finished", [audio_stream])
    audio_stream.play()

func audio_weapon1_finished(audio_stream):
    self.remove_child(audio_stream)

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
                $PlayerCamera.set_offset(Vector2(
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

        var collision = move_and_collide(movement * speed * delta)

        if collision and not('PlasmaShot' in collision.collider.name) and not('LaserBeam2D' in collision.collider.name):
            cancel_hyper_speed()
            rpc('sync_speed', speed)

        # rset("puppet_position", movement * speed * delta)
        rset_unreliable("puppet_global_position", position)
    else:
        self.rotation = puppet_direction
        self.position = puppet_global_position

    var player_id = int(name)

    if network.players.has(player_id):
        network.update_position(int(name), position)
    else:
        queue_free()
        
    if ghost && !_high_speed():
        self.remove_child(ghost)

    # cancel high speed & if uncommented sync with sound
    # if Input.get_action_strength("ui_down") && _high_speed():
    #    speed = default_speed
    #    rpc('sync_speed', speed)

func get_movement() -> Vector2:

    if(_high_speed()):
        return Vector2(cos(self.rotation), sin(self.rotation))

    if not is_network_master():
        return Vector2(cos(self.rotation), sin(self.rotation))

    return Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )

func cancel_hyper_speed():
    $ParticlesCharge.emitting = false
    $ParticlesBoost.emitting = false
    speed = default_speed
    $Hyperjump.stop()
    charge =  false

puppet func remote_shield(new_shield):
    shield = new_shield

    if shield <= 0:
        shield_node.visible = false
    else:
        shield_node.visible = true

remotesync func remote_destroyed(attacker):
    Stats.update_table(attacker, int(self.name))
    Wall.report_death(attacker, int(self.name))
    self.ship_destruction()

puppet func remote_ship_resurection(new_position):
    self.position = new_position
    self.ship_resurection()

# called to cancel high speed in other players
puppet func sync_speed(new_speed):
    speed = new_speed


remotesync func init_charge(data):
    if not is_network_master():
        self.rotation = data.rotation
        self.position = data.position

    $Hyperjump.play()

    charge =  true
    $ParticlesCharge.emitting = true
    yield(get_tree().create_timer(0.5), "timeout")

    if die:
        return

    $ParticlesBoost.emitting = true
    charge =  false

    yield(get_tree().create_timer(0.3), "timeout")

    if die:
        return

    speed = boost_speed


func _unhandled_input(event: InputEvent) -> void:
    if die:
        return

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
            position = position,
        })

remotesync func fire_secondary_weapon(data):
    laser.is_casting = data.plasma

    if laser.is_casting:
        $Weapon2Sound.play()
    else:
        $Weapon2Sound.stop()

    if not is_network_master():
        self.rotation = data.rotation
        self.position = data.position

remotesync func plasma_shot(data):
    if not is_network_master():
        self.rotation = data.rotation
        self.position = data.position

    weapon1_sound()

    var projectile = plasma.instance()

    projectile.player_owner = int(self.name)

    if _high_speed():
        projectile.speed = (speed - default_speed) + projectile.default_speed

    projectile.global_position = $InitProjectile.global_position
    projectile.direction = Vector2(cos(self.rotation), sin(self.rotation))
    projectile.modulate = color

    $'/root/Main'.add_child(projectile)

func init(player_info):
    color = Global.colors[player_info.num]

    $Sprite.modulate = color
    $Trail2D.modulate = color
    $LaserBeam2D.modulate = color
    $LaserBeam2D/BeamParticles2D.modulate = color
    $LaserBeam2D/CastingParticles2D.modulate = color
    $LaserBeam2D/CollisionParticles2D.modulate = color
    $Shield.modulate = color

    $LaserBeam2D/CastingParticles2D.modulate = color
    $LaserBeam2D/BeamParticles2D.modulate = color
    $LaserBeam2D/CollisionParticles2D.modulate = color

    global_position.x = Global._random_between(-2000, 2000)
    global_position.y = Global._random_between(-2000, 2000)

func _high_speed():
    return speed > default_speed

func _on_ShipTrail_timeout():
    if (_high_speed() and HYPERJUMP_TRAIL_ACTIVE):
        var move_vector = get_movement()
        if (move_vector.x != 0 || move_vector.y != 0):
            # first make a copy of ghost object
            ghost = ghost_trail.instance()
            # give the ghost a parent
            get_parent().add_child(ghost)
            ghost.position = position
            var _scale = Vector2(.7, .7)
            ghost.set_scale(_scale)
            ghost.modulate.a = 0.5
            var dir = ghost.get_angle_to( get_global_mouse_position())+90 # TODO: fix
            ghost.rotation += dir

func ship_destruction():
    die = true
    explosion_instance = explosion.instance()
    self.add_child(explosion_instance)
    $Sprite.visible = false
    $CollisionShape2D.disabled = true
    Trail.is_emitting = false
    cancel_hyper_speed()
    $ShipDestuctionSound.play()
    laser.is_casting = false

func ship_resurection():
    self.remove_child(explosion_instance)

    $Sprite.visible = true
    $CollisionShape2D.disabled = false
    die = false
    hull = Global.PLAYER_HULL
    shield = Global.PLAYER_SHIELD
    shield_node.visible = true

    yield(get_tree().create_timer(1), 'timeout')
    Trail.is_emitting = true

func heal(amount):
    if hull + amount > Global.PLAYER_HULL:
        hull = Global.PLAYER_HULL
    else:
        hull += amount

    ui._on_damage_hull(hull)

func damage(who, amount):
    if is_network_master():
        enable_charge_shield = false
        if charge_shield_timer:
            self.remove_child(charge_shield_timer)

        charge_shield_timer = Timer.new()
        add_child(charge_shield_timer)
        charge_shield_timer.connect("timeout", self, "_init_charge_shield")
        charge_shield_timer.set_wait_time(5)
        charge_shield_timer.set_one_shot(true)
        charge_shield_timer.start()

        if shield > 0:
            shield = shield - amount

            ui._on_damage_shield(shield)

        if shield <= 0 && hull > 0:
            shield_node.visible = false

            if shield < 0:
                hull = hull + shield
                shield = 0
            else:
                hull = hull - amount

            ui._on_damage_hull(hull)

            if shield == 0:
                rpc("remote_shield", 0)

        if hull <= 0 && !die:
            rpc("remote_destroyed", who)

            yield(get_tree().create_timer(2), 'timeout')

            if is_network_master():
                RESPAWAN.init()

            yield(get_tree().create_timer(RESPAWAN.init_time), 'timeout')

            global_position.x = Global._random_between(-2000, 2000)
            global_position.y = Global._random_between(-2000, 2000)

            self.ship_resurection()
            rpc("remote_ship_resurection", self.position)

            ui._on_damage_shield(shield)
            ui._on_damage_hull(hull)


