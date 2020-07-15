extends KinematicBody2D

const MAX_POSITION = 2000
const VELOCITY = 3000
const MIN_VELOCITY = 10
const MAX_VELOCITY = 100 #20
const ROTATION_DEGREES = 4
const MIN_SCALE_FACTOR = 0.7
const MAX_SCALE_FACTOR = 1.3
onready var tween := $Tween
onready var sprite := $Sprite
onready var animation := $AnimationPlayer

var explosion = preload('res://Explosion/Explosion.tscn')

export var emission_color: Gradient = Gradient.new() setget _set_gradient

var rnd = RandomNumberGenerator.new()
var velocity = Vector2()
var shoot_received = 0

export var id = 0;

var destroying = false

func _ready():
    sprite.material = sprite.material.duplicate()
    
    if is_network_master(): 
        set_rotation_degrees(_random_between(0, 360))
        _set_random_velocity()
        _set_random_position()
        _set_random_size()
    
func _process(delta):
    if is_network_master(): 
        rotation_degrees += ROTATION_DEGREES * delta    
        
    if shoot_received > 0 && shoot_received < 5:
        var glow = float(shoot_received) / 10
    
        sprite.self_modulate = Color(1 + glow, 1, 1) 

func _physics_process(delta):
    if is_network_master(): 
        move_and_collide(velocity * delta)
        Network.update_asteroid(self.get_instance_id(), position, rotation_degrees, get_scale())

func _set_random_position():
    global_position.x = _random_between(-MAX_POSITION, MAX_POSITION)
    global_position.y = _random_between(-MAX_POSITION, MAX_POSITION)

func _set_random_velocity():
    velocity.y = _random_between(-VELOCITY, VELOCITY) # randomizes the x component of the velocity
    velocity.x = _random_between(-VELOCITY, VELOCITY) # randomizes the y component of the velocity
    velocity = velocity.normalized() * _random_between(MIN_VELOCITY,MAX_VELOCITY)    

func _set_random_size():
    var _scaleFactor = _random_between(MIN_SCALE_FACTOR, MAX_SCALE_FACTOR)
    var _scale = Vector2(_scaleFactor, _scaleFactor)
    set_scale(_scale)

func _random_between(minRnd, maxRnd):
    rnd.randomize()
    return rnd.randf_range(minRnd, maxRnd)
    
func remote_update(update):
    set_scale(update.scale)
    position = update.position
    rotation_degrees = update.rotation_degrees

func _set_gradient(value: Gradient) -> void:
    emission_color = value

func dissolve_amount(value: float) -> void:
    sprite.material.set_shader_param("dissolve_amount", value)

func dissolve_color(value: float) -> void:
    sprite.material.set_shader_param("burn_color", emission_color.interpolate(value))

func delete():
    Network.erase_asteroid(self.get_instance_id())
    queue_free()

func disolve():
    if not destroying:
        destroying = true
        tween.interpolate_method(
            self, "dissolve_amount", 0, 1, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT
        )
        tween.interpolate_method(
            self, "dissolve_color", 0, 1, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT
        )
        tween.start()
        yield(tween, "tween_all_completed")
        self.delete()
    
func shoot(): 
    shoot_received += 1
    
    if shoot_received == 5:
        animation.play("Explosion")
    
        yield(get_tree().create_timer(1.6), 'timeout')
        self.add_child(explosion.instance())
        yield(get_tree().create_timer(3), 'timeout')
        self.delete()
        
        
        
