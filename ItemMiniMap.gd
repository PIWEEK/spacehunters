extends Node2D

var id = 0
var type = ''
const PLAYER_TEXTURE = preload("res://Assets/player.png")
const ASTEROID_TEXTURE = preload("res://Assets/asteroid.png")
const ENEMY_TEXTURE = preload("res://Assets/enemy.png")

func _process(delta: float) -> void:
    if self.type == 'player' || self.type == 'enemy':
        if !Network.players.has(id):
            queue_free()
    elif self.type == 'asteroid':
        if !Network.asteroids.has(id):
            queue_free()            

func init(id, type):
    self.id = id
    self.type = type
    
    if type == 'player':
        $Sprite.texture = PLAYER_TEXTURE
    elif type == 'asteroid':
        $Sprite.texture = ASTEROID_TEXTURE
    elif type == 'enemy':
        $Sprite.texture = ENEMY_TEXTURE        

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
