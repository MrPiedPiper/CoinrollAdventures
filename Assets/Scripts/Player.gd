extends KinematicBody2D

export var acceleration = 700
export var topSpeed = 150
export var jumpPower = -13000
export var shootVel = 200
export var gravity = 300
export var bullet : PackedScene

var bulletCooldown = 0.3
var pickupCooldown = 0.3

var canShoot = true
var canPickup = true

var touchingCoins = []

var frictionAmount = 0.2

var velocity : Vector2

var up = Vector2(0, -1)

func _ready():
	randomize()

func _process(delta):
	print(touchingCoins)
	rotatePlayerByMovement()

func _physics_process(delta):
	#Add in Gravity
	velocity.y += gravity * delta
	#Do the Movement
	velocity = movePlayer(velocity, delta)
	#Call the build in movement function
	velocity = move_and_slide(velocity, up)
	#Call the shoot function
	shoot()
	#Call the pickup function
	pickup()

func rotatePlayerByMovement():
	if Input.is_action_pressed("ui_right"):
		$RotationNode.scale.x = 1
	if Input.is_action_pressed("ui_left"):
		$RotationNode.scale.x = -1

#movePlayer moves the player by calling walk() and jump() return modified Vector2
func movePlayer(inputVelocity, inputDelta):
	var newVel = inputVelocity
	#Call the walk function to add horizontal movement
	newVel = walk(newVel, inputDelta)
	#Script for jumping
	newVel = jump(newVel, inputDelta)
	return newVel

#Script for horizontal movement returns modified Vector2
func walk(inputVelocity, inputDelta):
	var newVel = inputVelocity
	#Preset the hasFriction variable for simplicity
	var hasFriction = true
	#If the player is pressing right
	if Input.is_action_pressed("ui_right"):
		#Add to the velocity
		newVel.x += acceleration * inputDelta
		#And set hasFriction to false
		hasFriction = false
	#If the player is pressing left
	if Input.is_action_pressed("ui_left"):
		#Add to the velocity
		newVel.x -= acceleration * inputDelta
		#And set hasFriction to false
		hasFriction = false
	if hasFriction:
		newVel.x = lerp(newVel.x, 0, frictionAmount)
	newVel.x = clamp(newVel.x, -topSpeed, topSpeed)
	return newVel

#Script for jumping movement returns modified Vector2
func jump(inputVelocity, inputDelta):
	if !is_on_floor():
		return inputVelocity
	var newVel = inputVelocity
	if Input.is_action_pressed("move_jump"):
		newVel.y = jumpPower * inputDelta
	return newVel

func shoot():
	if Input.is_action_just_pressed("player_shoot") and canShoot:
		var newBullet = bullet.instance()
		get_tree().get_root().get_child(0).get_node("ActiveBullets").add_child(newBullet)
		newBullet.global_position = $RotationNode/BulletSpawn.global_position
		var shootDir
		if $RotationNode.scale.x > 0:
			shootDir = 1
		else:
			shootDir = -1
		newBullet.linear_velocity = Vector2(shootVel * shootDir, 0)
		canShoot = false
		yield(get_tree().create_timer(bulletCooldown), "timeout")
		canShoot = true

func pickup():
	if Input.is_action_pressed("player_pickup") and canPickup and touchingCoins.size() > 0:
		var selectedCoin
		for i in range(0, touchingCoins.size()):
			if i == 0:
				selectedCoin = touchingCoins[i]
			else:
				var currYDiff = abs(self.position.y - touchingCoins[i].position.y)
				var newYDiff = abs(self.position.y - selectedCoin.position.y)
				if currYDiff < newYDiff:
					selectedCoin = touchingCoins[i]
				elif currYDiff == newYDiff:
					var currXDiff = abs(self.position.x - touchingCoins[i].position.x)
					var newXDiff = abs(self.position.x - selectedCoin.position.x)
					if currXDiff < newXDiff:
						selectedCoin = touchingCoins[i]
					
		touchingCoins.erase(selectedCoin)
		selectedCoin.queue_free()
		canPickup = false
		yield(get_tree().create_timer(bulletCooldown), "timeout")
		canPickup = true

func _on_PlayerArea2D_area_entered(area):
	if area.is_in_group("CoinDown"):
		touchingCoins.append(area.get_parent())

func _on_PlayerArea2D_area_exited(area):
	if area.is_in_group("CoinDown"):
		touchingCoins.erase(area.get_parent())

















