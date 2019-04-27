extends KinematicBody2D

var velocity : Vector2
export var gravity = 300
var up = Vector2(0, -1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, up)
