extends Control

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
    network.create_server(username.text)
    start_game()
    
func _join_pressed():
    start_game()
    global.is_server = false
    global.ip = ip.text
    global.username = username.text
    network.connect_to_server(global.username, global.ip)
    
func start_game():
    get_tree().change_scene("res://Main.tscn")
