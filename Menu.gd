extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var join_button = $Client/VBoxContainer/HBoxContainer/Join
onready var create_button = $Client/VBoxContainer/HBoxContainer/Create
onready var ip = $Client/VBoxContainer/Ip
onready var username = $Client/VBoxContainer/Username

onready var global = get_node("/root/Global")
onready var network = get_node("/root/Network")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    create_button.connect("pressed", self, '_create_pressed')
    join_button.connect("pressed", self, '_join_pressed')

func _create_pressed():
    global.is_server = true
    network.create_server('admin')
    start_game()
    
func _join_pressed():
    print('join');
    global.is_server = false
    global.ip = ip.text
    global.username = username.text
    network.connect_to_server(username, ip)
    start_game()
    
func start_game():
    get_tree().change_scene("res://Main.tscn")
