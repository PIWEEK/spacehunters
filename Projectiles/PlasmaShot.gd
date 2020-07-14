extends KinematicBody2D

onready var player := $AnimationPlayer
onready var tween := $Tween
onready var sprite := $Sprite

export var default_speed := 1000.0
export var speed := 1000.0
export var damage := 10.0
export var direction: Vector2

# fill in instanciation
var shooter: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    player.play("Flicker")
    sprite.material = sprite.material.duplicate()

func _physics_process(delta: float) -> void:
    var collision := move_and_collide(direction * speed * delta)
    
    if collision:
       destroy()

func destroy() -> void:
    self.set_physics_process(false)
    self.get_node("CollisionShape2D").disabled = true
    
    tween.interpolate_method(self, "_fade", 1.0, 0.0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    tween.start()
    yield(tween, "tween_all_completed")
    queue_free()

func _fade(value: float) -> void:
    sprite.material.set_shader_param("fade_amount", value)
