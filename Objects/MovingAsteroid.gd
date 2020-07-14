extends KinematicBody2D

const MAX_POSITION = 2500
const VELOCITY = 3000
const MIN_VELOCITY = 10
const MAX_VELOCITY = 100 #20
const ROTATION_DEGREES = 4
const MIN_SCALE_FACTOR = 0.7
const MAX_SCALE_FACTOR = 1.3

var rnd = RandomNumberGenerator.new()
var velocity = Vector2()

export var id = 0;

func _ready():
    if is_network_master(): 
        set_rotation_degrees(_random_between(0, 360))
        _set_random_velocity()
        _set_random_position()
        _set_random_size()
    
func _process(delta):
    if is_network_master(): 
        rotation_degrees += ROTATION_DEGREES * delta    

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
    
