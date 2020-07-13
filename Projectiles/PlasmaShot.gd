extends KinematicBody2D

onready var player := $AnimationPlayer

export var speed := 1000.0
export var damage := 10.0
export var direction: Vector2

# fill in instanciation
var shooter: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    player.play("Flicker")

func _physics_process(delta: float) -> void:
    var collision := move_and_collide(direction * speed * delta)
    
    if collision:
       destroy()

func destroy() -> void:
    queue_free()
