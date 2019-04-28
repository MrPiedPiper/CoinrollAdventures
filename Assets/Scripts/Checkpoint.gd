extends Node2D

var activeTexture = preload("res://Assets/Sprites/FlagSprites/FlagTop.png")
var deactiveTexture = preload("res://Assets/Sprites/FlagSprites/FlagBottom.png")

var active = false

func _checkpoint_activated():
	if active == false:
		$Sprite.texture = activeTexture
		$AudioStreamPlayer.play()
		active = true

func _checkpoint_deactivated():
	active = false
	$Sprite.texture = deactiveTexture