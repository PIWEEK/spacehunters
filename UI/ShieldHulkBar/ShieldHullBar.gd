extends Control

var rng = RandomNumberGenerator.new()

onready var ShieldBar = $ShieldBar;
onready var HullBar = $HullBar;
onready var ShieldTween = $ShieldBar/ShieldTween
onready var HullTween = $HullBar/HullTween


var hull := 300
var shield := 100
var max_hull := 300
var max_shield := 100
var minInt := 0

onready var anim_player := $AnimationPlayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    # Set Bars Maxs.
    ShieldBar.max_value = max_shield
    ShieldBar.value = max_shield
    HullBar.max_value = max_hull
    HullBar.value = max_hull

    # Paint Numbers
    $HullText.bbcode_text = str(hull)
    $ShieldText.bbcode_text = str(shield)
    
    var timer = Timer.new()
    timer.connect("timeout", self, "_on_damage")
    add_child(timer)
    timer.wait_time = 2
    timer.start()
    pass # Replace with function body.
    
func _process(delta):
    print(shield, ' ', ShieldTween.is_active())
    HullBar.value = hull
    ShieldBar.value = shield
    
func _on_damage():
    if shield >= 0:
        var new_shield = shield - rng.randf_range(10.0, 40.0)
        _update_shield(shield, new_shield)
    if shield == 0:
        var new_hull = hull - rng.randf_range(10.0, 40.0)
        _update_hull(hull, new_hull)

func _update_hull(value_start: float, current_value: float):
    if current_value > 0:
        HullTween.interpolate_property(
            self, "hull", hull, current_value, 0.25, Tween.TRANS_ELASTIC, Tween.EASE_OUT
        )
    else:
        HullTween.interpolate_property(
            self, "hull", hull, 0, 0.25, Tween.TRANS_ELASTIC, Tween.EASE_OUT
        )
    if current_value > 0:
        $HullText.bbcode_text = str(current_value)
    else:
        $HullText.bbcode_text = str(0)
        
    if not HullTween.is_active():
        HullTween.start()

func _update_shield(value_start: float, current_value: float):
    if current_value > 0:
        ShieldTween.interpolate_property(
            self, "shield", shield, current_value, 0.25, Tween.TRANS_ELASTIC, Tween.EASE_OUT
        )
    else :
        ShieldTween.interpolate_property(
            self, "shield", shield, 0, 0.25, Tween.TRANS_ELASTIC, Tween.EASE_OUT
        )
    if current_value > 0:
        $ShieldText.bbcode_text = str(current_value)
    else:
        $ShieldText.bbcode_text = str(0)
        
    if not ShieldTween.is_active():
        ShieldTween.start()        

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
