extends Node2D

var activeTexture = preload("res://Assets/Sprites/FlagSprites/FlagTop.png")
var deactiveTexture = preload("res://Assets/Sprites/FlagSprites/FlagBottom.png")

var active = false

func _checkpoint_activated():
	active = true
	$Sprite.texture = activeTexture

func _checkpoint_deactivated():
	print("not active")
	active = false
	$Sprite.texture = deactiveTexture