extends Node2D

onready var curr_level = $CurrLevel.get_child(0)

func _ready():
	connect_signal()

func _change_level():
	var new_level = curr_level.next_level.instance()
	$CurrLevel.remove_child(curr_level)
	curr_level.call_deferred("free")
	$CurrLevel.add_child(new_level)
	curr_level = new_level
	connect_signal()

func connect_signal():
	curr_level.connect("change_level", self, "_change_level")