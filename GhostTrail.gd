extends Sprite

const TRAIL_DURATION = 0.5 # seconds

# Called when the node enters the scene tree for the first time.
func _ready():
    _fade_ship_timer()
#    Tween.interpolate_propery(self, "modulate", Color(1,1,1,1), Color(1,1,1,0),.6, Tween.TRANS_SINE, Tween.EASE_OUT)
#    Tween.start()

func _fade_ship_timer():
    var _timer = Timer.new()
    add_child(_timer)
    _timer.connect("timeout", self, "_on_Timer_timeout")
    _timer.set_wait_time(TRAIL_DURATION)
    _timer.set_one_shot(false) # Make sure it loops
    _timer.start()

func _on_Timer_timeout():
    visible = false

func _on_Tween_tween_completed(object, key):
    queue_free()
