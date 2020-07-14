extends KinematicBody2D

const MAX_POSITION = 2500
const VELOCITY = 3000
const MIN_VELOCITY = 10
const MAX_VELOCITY = 100 #20
const ROTATION_DEGREES = 4

var rnd = RandomNumberGenerator.new()
var velocity = Vector2()

func _ready():
    set_rotation_degrees(_random_between(0, 360))

    velocity.y = _random_between(-VELOCITY, VELOCITY) # randomizes the x component of the velocity
    velocity.x = _random_between(-VELOCITY, VELOCITY) # randomizes the y component of the velocity
    velocity = velocity.normalized() * _random_between(MIN_VELOCITY,MAX_VELOCITY)

    global_position.x = _random_between(-MAX_POSITION, MAX_POSITION)
    global_position.y = _random_between(-MAX_POSITION, MAX_POSITION)
    
func _process(delta):
    rotation_degrees += ROTATION_DEGREES * delta    

func _physics_process(delta):
    move_and_collide(velocity * delta)

func _random_between(minRnd, maxRnd):
    rnd.randomize()
    return rnd.randf_range(minRnd, maxRnd)
    

    
