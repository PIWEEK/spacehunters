extends Node2D

onready var global = get_node("/root/Global")
onready var game_stats := $CanvasLayer/Players

func _ready() -> void:    
    $MainSceneMusic.play()
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
    
    if get_tree().is_network_server():
        Network.create_ship(1, Network.self_data)
    
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    if event.is_action_pressed("confine_mouse"):
        Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)      

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action("show_game_stats"):        
        game_stats.visible = Input.is_action_pressed("show_game_stats")
