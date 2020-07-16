extends Node2D

const TIMER = 10

var healing_body

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $ChargingParticles.modulate = '00b0ff'
    var _timer = Timer.new()
    add_child(_timer)
    _timer.connect("timeout", self, "_on_Timer_timeout")
    _timer.set_wait_time(TIMER)
    _timer.set_one_shot(false) # Make sure it loops
    _timer.start()
    
    var healing_timer = Timer.new()
    add_child(healing_timer)
    healing_timer.connect("timeout", self, "_heal")
    healing_timer.set_wait_time(1)
    healing_timer.set_one_shot(false) # Make sure it loops
    healing_timer.start()    

func _on_Timer_timeout():
    global_position.x = Global._random_between(-2000, 2000)
    global_position.y = Global._random_between(-2000, 2000)
    
func _heal():
    if healing_body:
        healing_body.heal(40)

func _on_Area2D_body_entered(body: Node) -> void:
    if body.is_in_group('ship'):
        healing_body = body

func _on_Area2D_body_exited(body: Node) -> void:
    healing_body = null
