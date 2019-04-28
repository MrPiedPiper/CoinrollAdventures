extends Node2D

signal button_activated
signal button_deactivated

export var linkedObjectPath : NodePath
var linkedObject
var deactiveSprite : Texture = preload("res://Assets/Sprites/ButtonUp.png")
var activeSprite : Texture = preload("res://Assets/Sprites/ButtonDown.png")
var last_result = false
var collision

var collidingWith = []

func _ready():
	if linkedObjectPath != null:
		var linkedObject = get_node(linkedObjectPath)
		connect("button_activated", linkedObject, "_on_activated", [collidingWith])
		connect("button_deactivated", linkedObject, "_on_deactivated", [collidingWith])
		

func _process(delta):
	collision = $RayCast2D
	if collision.is_colliding() != last_result:
		if collision.get_collider() != null:
			emit_signal("button_activated")
			$Sprite.texture = activeSprite
			last_result = true
		else:
			emit_signal("button_deactivated")
			$Sprite.texture = deactiveSprite
			last_result = false

