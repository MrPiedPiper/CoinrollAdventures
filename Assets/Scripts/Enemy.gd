extends KinematicBody2D

export var hasCoin = false

var isCyclingRay = false

#If the Enemy sees the player within range and doesn't ahve a coin, have the Enemy run towards the plyaer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	cycleRay()
	
func cycleRay():
	if isCyclingRay:
		return
	var coins = get_tree().get_root().get_child(0).get_node("InactiveBullets").get_children()
	var allCoinPositions = []
	for i in range(0, coins.size()):
		allCoinPositions.append(coins[i].position)
	allCoinPositions.append(get_tree().get_root().get_child(0).get_node("Player").position)
	allCoinPositions.sort_custom(self, "closest_coin_sort")
	isCyclingRay = true
	for i in range(0, allCoinPositions.size()):
		var angle = get_angle_to(allCoinPositions[i])
		$RayCast2D.rotation = angle - PI/2
		if $RayCast2D.is_colliding():
			print($RayCast2D.get_collider().name)
			pass
		yield(get_tree().create_timer(.1), "timeout")
	isCyclingRay = false
	
func closest_coin_sort(a, b):
	if (position.x - a.x) + (position.y - a.y) < (position.x - b.x) + (position.y - b.y):
		return true
	else:
		return false