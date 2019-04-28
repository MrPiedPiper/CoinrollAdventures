extends Node2D

var deactiveSprite : Texture = preload("res://Assets/Sprites/GateClosed.png")
var activeSprite : Texture = preload("res://Assets/Sprites/GateOpen.png")

var activeArray = []

func _on_activated(_node):
	activeArray.append(_node)
	process_gate()
	
func _on_deactivated(_node):
	activeArray.erase(_node)
	process_gate()
	
func process_gate():
	if activeArray.size() > 0:
		$KinematicBody2D/CollisionShape2D.set_deferred("disabled", true)
		$Sprite.texture = activeSprite
	else:
		$KinematicBody2D/CollisionShape2D.set_deferred("disabled", false)
		$Sprite.texture = deactiveSprite