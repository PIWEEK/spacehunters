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
    
func _on_damage_shield(new_shield, ease_type = Tween.EASE_OUT):
    shield = new_shield
    
    if new_shield < 0:
        _update_shield(shield, 0, ease_type)
    else:
        _update_shield(shield, new_shield, ease_type)
    
        
func _on_damage_hull(new_hull, ease_type = Tween.EASE_OUT):
    hull = new_hull
    if new_hull < 0:
        _update_hull(hull, 0, ease_type)
    else:
        _update_hull(hull, new_hull, ease_type)        

func _update_hull(value_start: float, current_value: float, ease_type = Tween.EASE_OUT):
    if current_value > 0:
        HullTween.interpolate_property(
            self, "hull", hull, current_value, 0.25, Tween.TRANS_ELASTIC, ease_type
        )
    else:
        HullTween.interpolate_property(
            self, "hull", hull, 0, 0.25, Tween.TRANS_ELASTIC, ease_type
        )

    if not HullTween.is_active():
        HullTween.start()

func _update_shield(value_start: float, current_value: float, ease_type = Tween.EASE_OUT):
    if current_value > 0:
        ShieldTween.interpolate_property(
            self, "shield", shield, current_value, 0.25, Tween.TRANS_ELASTIC, ease_type
        )
    else :
        ShieldTween.interpolate_property(
            self, "shield", shield, 0, 0.25, Tween.TRANS_ELASTIC, ease_type
        )
        
    if not ShieldTween.is_active():
        ShieldTween.start()        

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
