extends RayCast2D

export var cast_speed := 7000.0
export var max_length := 1400
export var growth_time := 0.1

var is_casting := false setget set_is_casting

onready var fill := $FillLine2D
onready var tween := $Tween
onready var casting_particles := $CastingParticles2D
onready var collision_particles := $CollisionParticles2D
onready var beam_particles := $BeamParticles2D

onready var line_width: float = fill.width
var damage_rate = 0.05
var timer = null
var player_owner;

func _ready() -> void:
    set_physics_process(false)
    fill.points[1] = Vector2.ZERO


func _physics_process(delta: float) -> void:
    cast_to = (cast_to + Vector2.RIGHT * cast_speed * delta).clamped(max_length)
    cast_beam()


func set_is_casting(cast: bool) -> void:
    is_casting = cast

    if is_casting:
        cast_to = Vector2.ZERO
        fill.points[1] = cast_to
        appear()
    else:
        collision_particles.emitting = false
        disappear()
        self.check_current_damage()

    set_physics_process(is_casting)
    beam_particles.emitting = is_casting
    casting_particles.emitting = is_casting

func make_damage_ship(ship):
    if ship:
        ship.damage(player_owner, 3)

func damage_ship(ship):
    if !timer:
        timer = Timer.new()
        timer.connect("timeout", self, "make_damage_ship", [ship]) 
        timer.wait_time = damage_rate
        add_child(timer)
        timer.start() 

func cast_beam() -> void:
    var cast_point := cast_to

    force_raycast_update()
    collision_particles.emitting = is_colliding()

    if is_colliding():
        var collider = get_collider()
        
        if collider.is_in_group('asteroid'):
            collider.disolve()
        elif collider.is_in_group('ship'):
            self.damage_ship(collider)
        elif timer:
            self.check_current_damage()
            
        cast_point = to_local(get_collision_point())
        collision_particles.global_rotation = get_collision_normal().angle()
        collision_particles.position = cast_point
    else:
        self.check_current_damage()

    fill.points[1] = cast_point
    beam_particles.position = cast_point * 0.5
    beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5

func check_current_damage():
    if timer:
        timer.stop()
        self.remove_child(timer)
        timer = null

func appear() -> void:
    if tween.is_active():
        tween.stop_all()
    tween.interpolate_property(fill, "width", 0, line_width, growth_time * 2)
    tween.start()


func disappear() -> void:
    if tween.is_active():
        tween.stop_all()
    tween.interpolate_property(fill, "width", fill.width, 0, growth_time)
    tween.start()
