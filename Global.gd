extends Node

var ip = ''
var username = ''
var is_server = false
var rnd = RandomNumberGenerator.new()

const PLAYER_HULL = 300
const PLAYER_SHIELD = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func _random_between(minRnd, maxRnd):
    rnd.randomize()
    return rnd.randf_range(minRnd, maxRnd)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
