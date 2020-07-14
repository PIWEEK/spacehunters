extends Node2D

const ASTEROIDS_NUM = 40
const MOVING_ASTEROID = preload("res://Objects/MovingAsteroid.tscn")
const TIMER = 30.0 # seconds

puppet var remote_asteroids = {}

var _timer = null

func _ready():
    if is_network_master(): 
        _spawn_asteroids()
    # _spawn_asteroids_periodically()
    
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
        
func _process(delta: float) -> void:
    if is_network_master(): 
        rset_unreliable("remote_asteroids", Network.asteroids)
    else:
        Network.asteroids = remote_asteroids
        
        var asteroids = self.get_children()
        
        for asteroid_id in remote_asteroids:
            var asteroid = find_asteroid_by_id(asteroids, asteroid_id)
            
            if asteroid == null:
                var new_asteroid = MOVING_ASTEROID.instance()
                new_asteroid.name = str(asteroid_id)
                new_asteroid.id = asteroid_id
                new_asteroid.remote_update(remote_asteroids[asteroid_id])
                add_child(new_asteroid)             
            else:
                asteroid.remote_update(remote_asteroids[asteroid_id])
        
func find_asteroid_by_id(asteroids, id):
    for child in asteroids:
        if(child.id == id):
            return child

    return null

func _on_Timer_timeout():
    _spawn_asteroids()
