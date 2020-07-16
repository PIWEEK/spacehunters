extends Node2D

const ASTEROIDS_NUM = 40
const MOVING_ASTEROID = preload("res://Objects/MovingAsteroid.tscn")
const TIMER = 30.0 # seconds

puppet var remote_asteroids = {}

var _timer = null
var spawn_points = []

#asteroid_spawn_point

func _ready():
    if is_network_master():
        for child in $'/root/Main/'.get_children():
            if child.is_in_group('asteroid_spawn_point'):
                spawn_points.append(child)
                
        if spawn_points.size() > 0:
            self._spawn_asteroids_periodically_from_points()
        
        _spawn_asteroids()
    # _spawn_asteroids_periodically()
    
func _spawn_asteroids_periodically_from_points():
    _timer = Timer.new()
    add_child(_timer)
    _timer.connect("timeout", self, "_spawn_from_points")
    _timer.set_wait_time(5)
    _timer.set_one_shot(false)
    _timer.start()    
    
func _spawn_from_points():
    var spawn_point = Global._random_between(0, spawn_points.size())
    
    var asteroid = MOVING_ASTEROID.instance()
    asteroid.id = asteroid.get_instance_id()
    asteroid.master_init(false)
    asteroid.global_position = spawn_points[spawn_point].global_position
    asteroid.look_at(Vector2(0, 0))
    add_child(asteroid)
    
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
        asteroid.id = asteroid.get_instance_id()
        asteroid.master_init()
        add_child(asteroid)
        
func _process(delta: float) -> void:
    if is_network_master(): 
        rset_unreliable("remote_asteroids", Network.asteroids)
    else:
        Network.asteroids = remote_asteroids.duplicate()

        var asteroids = self.get_children()
        
        for asteroid_id in Network.asteroids:
            var asteroid = find_asteroid_by_id(asteroids, asteroid_id)
            
            if asteroid == null:
                var new_asteroid = MOVING_ASTEROID.instance()
                new_asteroid.name = str(asteroid_id)
                new_asteroid.id = asteroid_id
                new_asteroid.remote_update(Network.asteroids[asteroid_id])
                add_child(new_asteroid)             
            else:
                asteroid.remote_update(Network.asteroids[asteroid_id])
                
        remove_unused_asteroids(asteroids)
        
func remove_unused_asteroids(asteroids):
    for child in asteroids:
        if not Network.asteroids.has(child.id):
            child.queue_free()
        
func find_asteroid_by_id(asteroids, id):
    for child in asteroids:
        if(child.id == id):
            return child

    return null

func _on_Timer_timeout():
    _spawn_asteroids()
