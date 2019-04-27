extends Node2D

signal button_activated
signal button_deactivated

export var linkedObjectPath : NodePath
var linkedObject
var deactiveSprite : Texture = preload("res://Assets/Sprites/ButtonUp.png")
var activeSprite : Texture = preload("res://Assets/Sprites/ButtonDown.png")

var collidingWith = []

func _ready():
	if linkedObjectPath != null:
		var linkedObject = get_node(linkedObjectPath)
		connect("button_activated", linkedObject, "_on_activated", [self])
		connect("button_deactivated", linkedObject, "_on_deactivated", [self])

func _on_Area2D_area_entered(area):
	emit_signal("button_activated")
	collidingWith.append(area)
	$Sprite.texture = activeSprite


func _on_Area2D_area_exited(area):
	collidingWith.erase(area)
	if collidingWith.size()==0:
		emit_signal("button_deactivated")
		$Sprite.texture = deactiveSprite
