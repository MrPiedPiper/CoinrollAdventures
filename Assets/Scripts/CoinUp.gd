extends RigidBody2D

export var coinDown : PackedScene

var isTouchingPlayer = false
var isPlacing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if isPlacing and !isTouchingPlayer:
		placeCoin()

func _on_Area2D_body_entered(body):
	if body == self or body == $Area2D or body.is_in_group("Player"):
		return
	if isTouchingPlayer:
		isPlacing = true
		return
	placeCoin()

func placeCoin():
	var newCoin = coinDown.instance()
	get_tree().get_root().get_child(0).get_node("InactiveBullets").add_child(newCoin)
	newCoin.global_position = self.global_position
	self.queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group("Player"):
		isTouchingPlayer = true


func _on_Area2D_area_exited(area):
	if area.is_in_group("Player"):
		isTouchingPlayer = false
