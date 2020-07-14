extends Node2D

const ASTEROIDS_NUM = 40
const MOVING_ASTEROID = preload("res://Objects/MovingAsteroid.tscn")
const TIMER = 30.0 # seconds

var _timer = null

func _ready():
    _spawn_asteroids()
    _spawn_asteroids_periodically()
    
func _spawn_asteroids_periodically():
    _timer = Timer.new()
    add_child(_timer)
    _timer.connect("timeout", self, "_on_Timer_timeout")
    _timer.set_wait_time(TIMER)
    _timer.set_one_shot(false) # Make sure it loops
    _timer.start()

func _spawn_asteroids():
    for i in range(ASTEROIDS_NUM):
        # create a new instance of an asteroid scene
        var asteroid = MOVING_ASTEROID.instance()
        # add it as a child of this "universe"-node       
        add_child(asteroid)

func _on_Timer_timeout():
    _spawn_asteroids()
