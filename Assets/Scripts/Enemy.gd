extends KinematicBody2D

signal enemy_stole_coin

export var hasCoin = false
var isChasing = false
export var acceleration = 100
export var topSpeed = 35

onready var animator = $Body/AnimationPlayer

var og_has_coin = hasCoin
onready var og_position = self.position

var stunned = false
var stun_time : float = 1

var velocity = Vector2(0, 0)
var curr_target

var isCyclingRay = false

var touching = []

func _process(delta):
	handle_animation()
	if !hasCoin and !stunned:
		cycleRay()
		grab_coin()
	
func _physics_process(delta):
	if !hasCoin and !stunned:
		moveTowardsTarget(delta)

func cycleRay():
	if isCyclingRay:
		return
	var coins = get_tree().get_nodes_in_group("CoinDown")
	coins.append(get_tree().get_nodes_in_group("Player")[0])
	var positions = []
	for i in coins:
		positions.append(i.position)
	positions.sort_custom(self, "closest_coin_sort")
	isCyclingRay = true
	var collisions = []
	for i in range(0, coins.size()):
		var currObject = positions[i]
		if currObject != null:
			var angle = get_angle_to(currObject)
			$RayCast2D.rotation = angle - PI/2
			var collision = $RayCast2D
			if collision.is_colliding() and collision.get_collider() != null:
				if collision.get_collider().is_in_group("Player") or collision.get_collider().is_in_group("CoinDown"):
					curr_target = collision.get_collider().position
					break
			yield(get_tree().create_timer(.1), "timeout")
	isCyclingRay = false
	
func closest_coin_sort(a, b):
	#if (position.x - a.position.x) + (position.y - a.position.y) < (position.x - b.position.x) + (position.y - b.position.y):
	if (position.x - a.x) + (position.y - a.y) < (position.x - b.x) + (position.y - b.y):
		return false
	else:
		return true

func moveTowardsTarget(inputDelta):
	if curr_target == null:
		isChasing = false
		return
	isChasing = true
	var newVel = velocity
	if curr_target.x > position.x:
		$Body.scale.x = abs($Body.scale.x)
		newVel.x += acceleration * inputDelta
	if curr_target.x < position.x:
		$Body.scale.x = -abs($Body.scale.x)
		newVel.x -= acceleration * inputDelta
	velocity = move_and_slide(newVel)
	
func grab_coin():
	if hasCoin or stunned:
		return
	if touching.size() == 0:
		return
	for i in range(0, touching.size()):
		if touching[i].get_parent().is_in_group("CoinDown"):
			set_has_coin(true)
			touching[i].get_parent().call_deferred("free")
			break
		elif touching[i].get_parent().get_parent().is_in_group("Player"):
			set_has_coin(true)
			connect("enemy_stole_coin", touching[i].get_parent().get_parent(), "_enemy_stole_coin")
			emit_signal("enemy_stole_coin")

func set_has_coin(newValue):
	hasCoin = newValue
	if hasCoin:
		$KinematicBody2D/Sprite.visible = true
		$KinematicBody2D/CoinHitbox.disabled = false
	else:
		$KinematicBody2D/Sprite.visible = false
		$KinematicBody2D/CoinHitbox.disabled = true

func get_has_coin():
	return hasCoin

func _on_EnemyArea2D_area_entered(area):
	touching.append(area)

func _on_EnemyArea2D_area_exited(area):
	touching.erase(area)

func _player_stole_coin():
	set_has_coin(false)
	stunned = true
	yield(get_tree().create_timer(stun_time), "timeout")
	stunned = false

func respawn():
	set_has_coin(og_has_coin)
	position = og_position
	velocity = Vector2(0, 0)
	stunned = false
	isCyclingRay = false
	touching = []
	curr_target = null
	print(hasCoin)

func handle_animation():
	if hasCoin:
		animator.play("Happy")
	elif stunned:
		animator.play("Stun")
	elif isChasing:
		animator.play("Chase")
	else:
		animator.play("Idle")
	pass


























func _on_EnemyArea2D2_area_entered(area):
	pass # Replace with function body.


func _on_EnemyArea2D2_area_exited(area):
	pass # Replace with function body.
