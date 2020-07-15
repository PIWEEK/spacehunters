extends Node2D

const init_time = 3
var time = init_time
var timer = null

func init():
    self.visible = true
    time = init_time
    $RichTextLabel.text = str(init_time)
    
    timer = Timer.new()
    add_child(timer)
    
    timer.connect("timeout", self, "_on_Timer_timeout")
    
    timer.set_wait_time(1)
    timer.set_one_shot(false) # Make sure it loops
    timer.start()    

func _on_Timer_timeout():
    time -= 1
    
    if time == 0:
        self.visible = false
    else:
        $RichTextLabel.text = str(time)
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
