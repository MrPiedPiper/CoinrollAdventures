extends RigidBody2D

export var coinDown : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body):
	if body == self:
		return
	var newCoin = coinDown.instance()
	get_tree().get_root().get_child(0).get_node("InactiveBullets").add_child(newCoin)
	newCoin.global_position = self.global_position
	self.queue_free()
