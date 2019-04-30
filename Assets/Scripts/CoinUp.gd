extends RigidBody2D

export var coinDown : PackedScene

var isTouchingPlayer = false
var isPlacing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if isPlacing:
		placeCoin()

func _on_Area2D_body_entered(body):
	if body == self or body == $Area2D or body.is_in_group("Player"):
		return
	isPlacing = true

func placeCoin():
	var newCoin = coinDown.instance()
	get_node("../../InactiveBullets").call_deferred("add_child", newCoin)
	newCoin.global_position = self.global_position
	self.queue_free()


func _on_Area2D_area_entered(area):
	if area == self or area == $Area2D or area == $Area2D2 or area.is_in_group("PlayerArea") or area.is_in_group("SpringArea"):
		return
	isPlacing = true


func _on_Area2D_area_exited(area):
	if area.is_in_group("Player"):
		isTouchingPlayer = false
