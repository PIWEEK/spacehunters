extends Node

var ip = ''
var username = ''
var is_server = false
var rnd = RandomNumberGenerator.new()

const PLAYER_HULL = 300
const PLAYER_SHIELD = 100

const colors = [
    'ffab91',
    '1de9b6', 
    'ce93d8', 
    '7986cb', 
    'ffcc80',
    '00b0ff', 
    'ff9100', 
    'ef9a9a', 
    'fff59d',
    'bcaaa4',
    'ff3d00', 
    'eeff41', 
    '80deea', 
    '80cbc4', 
    'e6ee9c', 
    'ff5252', 
    'e040fb', 
    'ffd600', 
    'eeeeee',

]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func _random_between(minRnd, maxRnd):
    rnd.randomize()
    return rnd.randf_range(minRnd, maxRnd)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
