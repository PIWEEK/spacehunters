extends KinematicBody2D

const SPEED = 20
const MAX_POSITION = 1000

var rnd = RandomNumberGenerator.new()
var velocity = Vector2()

func _ready():
    rnd.randomize()
    velocity.y = rnd.randf_range(-300, 300) # randomizes the x component of the velocity
    rnd.randomize()
    velocity.x = rnd.randf_range(-300, 300) # randomizes the y component of the velocity
    velocity = velocity.normalized() * SPEED
    
    rnd.randomize()
    global_position.x = rnd.randf_range(-MAX_POSITION, MAX_POSITION)
    rnd.randomize()
    global_position.y = rnd.randf_range(-MAX_POSITION, MAX_POSITION)
    position += velocity * 1

func _physics_process(delta):
    move_and_collide(velocity * delta)
    move_and_collide(velocity * delta)
    #position += velocity * delta
