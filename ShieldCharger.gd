extends Node2D

const TIMER = 10

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var _timer = Timer.new()
    add_child(_timer)
    _timer.connect("timeout", self, "_on_Timer_timeout")
    _timer.set_wait_time(TIMER)
    _timer.set_one_shot(false) # Make sure it loops
    _timer.start()

func _on_Timer_timeout():
    global_position.x = Global._random_between(-2000, 2000)
    global_position.y = Global._random_between(-2000, 2000)
