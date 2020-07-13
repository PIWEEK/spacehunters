extends Node2D

const ASTEROIDS_NUM = 15
const MOVING_ASTEROID = preload("res://Objects/MovingAsteroid.tscn")

func _ready():
    loadMovingAsteroids()

func loadMovingAsteroids():
    for i in range(ASTEROIDS_NUM):
        # create a new instance of an asteroid scene
        var asteroid = MOVING_ASTEROID.instance()
        # add it as a child of this "universe"-node       
        add_child(asteroid)
