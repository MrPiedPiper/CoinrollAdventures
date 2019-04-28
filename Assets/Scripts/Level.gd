extends Node2D

signal change_level

export var next_level: PackedScene

onready var player = $Player

func _ready():
	player.connect("door_activated", self, "_player_door_activated")

func _player_door_activated():
	emit_signal("change_level")