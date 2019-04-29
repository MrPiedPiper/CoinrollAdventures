tool
extends Sprite

export var default_scale = Vector2(5, 5)

func _ready():
	calculate_aspect_ratio()

func calculate_aspect_ratio():
	material.set_shader_param("stretch_x", default_scale.x / scale.x)
	material.set_shader_param("stretch_y", default_scale.y / scale.y)
