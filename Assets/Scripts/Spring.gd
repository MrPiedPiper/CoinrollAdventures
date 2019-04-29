extends Node2D

signal launch

var deactiveSprite : Texture = preload("res://Assets/Sprites/SpringSprites/SpringShut.png")
var activeSprite : Texture = preload("res://Assets/Sprites/SpringSprites/SpringOpen.png")

var activeArray = []
var launchPower = -650

var touching = []

func _on_activated(_node):
	activeArray.append(_node)
	process_spring()
	
func _on_deactivated(_node):
	activeArray.erase(_node)
	process_spring()
	
func process_spring():
	if activeArray.size() > 0:
		$Sprite.texture = activeSprite
		bounce()
	else:
		$Sprite.texture = deactiveSprite

func bounce():
	for i in range(0, touching.size()):
		if touching[i].is_in_group("PlayerArea"):
			var currObject = touching[i].get_parent().get_parent() 
			connect("launch", currObject, "_launch", [rotation + PI/2, launchPower])
			emit_signal("launch")

func _on_Area2D_area_entered(area):
	touching.append(area)

func _on_Area2D_area_exited(area):
	touching.erase(area)



