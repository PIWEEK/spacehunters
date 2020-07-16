extends Camera2D

const MAX_ZOOM = 1.5
const MIN_ZOOM = 0.5

func zoom(delta):
    self.make_current()
    if Input.is_action_just_released("wheel_down"):
        print(get_zoom())
        if zoom.x < MAX_ZOOM:  # set a maximum zoom level
            self.zoom += Vector2(.05, .05)
    if Input.is_action_just_released('wheel_up'):
        print(get_zoom())
        if zoom.x > MIN_ZOOM:  # set a maximum zoom level
            self.zoom -= Vector2(5, 5) * delta  # add to the zoom every frame

func _process(delta):
    zoom(delta)
