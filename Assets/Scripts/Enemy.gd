extends KinematicBody2D

export var hasCoin = false
export var acceleration = 350
export var topSpeed = 75

var velocity = Vector2(0, 0)
var curr_target

var isCyclingRay = false

#If the Enemy sees the player within range and doesn't ahve a coin, have the Enemy run towards the plyaer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if !hasCoin:
		cycleRay()
	
func _physics_process(delta):
	if !hasCoin:
		moveTowardsTarget(delta)

func cycleRay():
	if isCyclingRay:
		return
	var coins = get_tree().get_root().get_child(0).get_node("InactiveBullets").get_children()
	coins.append(get_tree().get_root().get_child(0).get_node("Player"))
	coins.sort_custom(self, "closest_coin_sort")
	isCyclingRay = true
	var collisions = []
	for i in range(0, coins.size()):
		var angle = get_angle_to(coins[i].position)
		$RayCast2D.rotation = angle - PI/2
		var collision = $RayCast2D
		if collision.is_colliding() and collision.get_collider() != null:
			if collision.get_collider().is_in_group("Player") or collision.get_collider().is_in_group("CoinDown"):
				curr_target = collision.get_collider().position
				break
		yield(get_tree().create_timer(.1), "timeout")
	isCyclingRay = false
	
func closest_coin_sort(a, b):
	if (position.x - a.position.x) + (position.y - a.position.y) < (position.x - b.position.x) + (position.y - b.position.y):
		return false
	else:
		return true

func moveTowardsTarget(inputDelta):
	if curr_target == null:
		return
	var newVel = velocity
	if curr_target.x > position.x:
		newVel.x += acceleration * inputDelta
	if curr_target.x < position.x:
		newVel.x -= acceleration * inputDelta
	velocity = move_and_slide(newVel)






