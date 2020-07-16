extends Control

var rng = RandomNumberGenerator.new()

onready var ShieldBar = $ShieldBar;
onready var HullBar = $HullBar;
onready var ShieldTween = $ShieldBar/ShieldTween
onready var HullTween = $HullBar/HullTween

var hull = Global.PLAYER_HULL
var shield = Global.PLAYER_SHIELD
var max_hull := Global.PLAYER_HULL
var max_shield := Global.PLAYER_SHIELD
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
    
func _process(delta):
    HullBar.value = hull
    ShieldBar.value = shield
    
func _on_damage_shield(new_shield):
    if new_shield < 0:
        _update_shield(shield, 0)
    else:
        _update_shield(shield, new_shield)
    
        
func _on_damage_hull(new_hull):
    if new_hull < 0:
        _update_hull(hull, 0)
    else:
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
        
    if not ShieldTween.is_active():
        ShieldTween.start()        

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
