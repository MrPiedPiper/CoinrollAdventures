extends KinematicBody2D

signal player_stole_coin
signal checkpoint_activated
signal checkpoint_deactivated
signal door_activated

export var acceleration = 700
export var topSpeed = 150
export var jumpPower = -13000
export var shootVel = 200
export var gravity = 300
export var bullet : PackedScene

onready var head1 = preload("res://Assets/Sprites/PlayerSprites/Head/Head1.png")
onready var head2 = preload("res://Assets/Sprites/PlayerSprites/Head/Head2.png")
onready var head3 = preload("res://Assets/Sprites/PlayerSprites/Head/Head3.png")
onready var head4 = preload("res://Assets/Sprites/PlayerSprites/Head/Head4.png")
onready var head5 = preload("res://Assets/Sprites/PlayerSprites/Head/Head5.png")
onready var head6 = preload("res://Assets/Sprites/PlayerSprites/Head/Head6.png")

onready var headCollider1 = $Head1
onready var headCollider2 = $Head2
onready var headCollider3 = $Head3
onready var headCollider4 = $Head4
onready var headCollider5 = $Head5
onready var headCollider6 = $Head6

var coinStatModifier = 0.07

var currCheckpoint
var touchingCheckpoint = false
var touchingDoor = false

var maxCoins = 6
var bulletCooldown = 0.3
var pickupCooldown = 0.2
var aim_dir = Vector2(0, 0)

var canShoot = true
var canPickup = true

var touching = []

var touchingCoins = []
var heldCoins = maxCoins

var frictionAmount = 0.2
var velocity : Vector2
var up = Vector2(0, -1)

func _ready():
	randomize()

func _process(delta):
	set_aim_dir()
	rotatePlayerByMovement()
	#Call the pickup function
	pickup()
	steal_coin()
	check_respawn()
	check_door()

func _physics_process(delta):
	#Add in Gravity
	velocity.y += gravity * delta
	#Do the Movement
	velocity = movePlayer(velocity, delta)
	#Call the build in movement function
	velocity = move_and_slide(velocity, up)
	#Call the shoot function
	shoot()

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
		newVel.x += get_modified_stat(acceleration) * inputDelta
		#And set hasFriction to false
		hasFriction = false
	#If the player is pressing left
	if Input.is_action_pressed("ui_left"):
		#Add to the velocity
		newVel.x -= get_modified_stat(acceleration) * inputDelta
		#And set hasFriction to false
		hasFriction = false
	if hasFriction:
		newVel.x = lerp(newVel.x, 0, frictionAmount)
	elif !$Sounds/WalkSound.playing and is_on_floor():
		$Sounds/WalkSound.play(0)
	var modifiedTopSpeed = get_modified_stat(topSpeed)
	newVel.x = clamp(newVel.x, -modifiedTopSpeed, modifiedTopSpeed)
	return newVel

#Script for jumping movement returns modified Vector2
func jump(inputVelocity, inputDelta):
	if !is_on_floor():
		return inputVelocity
	var newVel = inputVelocity
	if Input.is_action_pressed("move_jump"):
		$Sounds/JumpSound.play(0)
		newVel.y = get_modified_stat(jumpPower) * inputDelta
	return newVel

func shoot():
	if Input.is_action_just_pressed("player_shoot") and canShoot and heldCoins > 1:
		var newBullet = bullet.instance()
		get_tree().get_root().get_child(0).get_node("ActiveBullets").add_child(newBullet)
		newBullet.global_position = $RotationNode/BulletSpawn.global_position
		var shootDir = aim_dir
		if $RotationNode.scale.x > 0:
			if shootDir == Vector2(0, 0):
				shootDir.x = 1
		else:
			if shootDir == Vector2(0, 0):
				shootDir.x = -1
		newBullet.linear_velocity = Vector2(shootVel, 0)
		newBullet.linear_velocity = newBullet.linear_velocity.rotated(shootDir.normalized().angle())
		canShoot = false
		setCoinCount(heldCoins-1)
		$Sounds/ShootSound.play(0)
		yield(get_tree().create_timer(bulletCooldown), "timeout")
		canShoot = true

func pickup():
	if Input.is_action_pressed("player_pickup") and canPickup and touchingCoins.size() > 0 and heldCoins < maxCoins:
		var selectedCoin
		for i in range(0, touchingCoins.size()):
			if touchingCoins[i] != null:
				if i == 0:
					selectedCoin = touchingCoins[i]
				elif selectedCoin != null:
					var currYDiff = abs(self.position.y - touchingCoins[i].position.y)
					var newYDiff = abs(self.position.y - selectedCoin.position.y)
					if currYDiff < newYDiff:
						selectedCoin = touchingCoins[i]
					elif currYDiff == newYDiff:
						var currXDiff = abs(self.position.x - touchingCoins[i].position.x)
						var newXDiff = abs(self.position.x - selectedCoin.position.x)
						if currXDiff < newXDiff:
							selectedCoin = touchingCoins[i]
		
		if selectedCoin != null:
			touchingCoins.erase(selectedCoin)
			selectedCoin.queue_free()
			canPickup = false
			setCoinCount(heldCoins + 1)
			$Sounds/PickupSound.play(0)
			yield(get_tree().create_timer(bulletCooldown), "timeout")
			canPickup = true

func _on_PlayerArea2D_area_entered(area):
	if area.is_in_group("CoinDown"):
		touchingCoins.append(area.get_parent())
	elif area.is_in_group("Checkpoint"):
		if currCheckpoint != null and currCheckpoint != area:
			connect("checkpoint_deactivated", currCheckpoint, "_checkpoint_deactivated", [], CONNECT_ONESHOT)
			emit_signal("checkpoint_deactivated")
		connect("checkpoint_activated", area.get_parent(), "_checkpoint_activated", [], CONNECT_ONESHOT)
		emit_signal("checkpoint_activated")
		currCheckpoint = area.get_parent()
		touchingCheckpoint = true
	elif area.is_in_group("DoorArea"):
		touchingDoor = true
	touching.append(area)
	
func _on_PlayerArea2D_area_exited(area):
	if area.is_in_group("CoinDown"):
		touchingCoins.erase(area.get_parent())
	elif area.is_in_group("Checkpoint"):
		touchingCheckpoint = false
	elif area.is_in_group("DoorArea"):
		touchingDoor = false
	touching.erase(area)

func get_modified_stat(inputStat):
	return (inputStat + (inputStat * (coinStatModifier * (maxCoins - heldCoins))))

func set_aim_dir():
	var newDir = Vector2()
	if Input.is_action_pressed("ui_up"):
		newDir.y -= 1
	if Input.is_action_pressed("ui_right"):
		newDir.x += 1
	if Input.is_action_pressed("ui_down"):
		newDir.y += 1
	if Input.is_action_pressed("ui_left"):
		newDir.x -= 1
	aim_dir = newDir

func _enemy_stole_coin():
	setCoinCount(heldCoins - 1)

func setCoinCount(newValue):
	heldCoins = newValue
	process_head()
	if heldCoins < 1:
		die()

func die():
	yield(get_tree().create_timer(2),"timeout")
	respawn()
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.respawn()

func steal_coin():
	if Input.is_action_pressed("player_pickup") and canPickup:
		for i in range(0, touching.size()):
			if touching[i] != null:
				var currObject = touching[i].get_parent()
				if currObject.is_in_group("Enemy") and currObject.get_has_coin():
					if heldCoins < maxCoins:
						connect("player_stole_coin", currObject, "_player_stole_coin")
						emit_signal("player_stole_coin")
						setCoinCount(heldCoins+1)
						canPickup = false
						$Sounds/PickupSound.play(0)
						yield(get_tree().create_timer(bulletCooldown), "timeout")
						canPickup = true
						return

func _launch(rot, power):
	var launchDir = Vector2(cos(rot), sin(rot))
	velocity += launchDir * power
	velocity = move_and_slide(velocity)

func respawn():
	var active_bullets = get_tree().get_root().get_child(0).get_node("ActiveBullets").get_children()
	for i in range(0, active_bullets.size()):
		active_bullets[i].queue_free()
	
	var inactive_bullets = get_tree().get_root().get_child(0).get_node("InactiveBullets").get_children()
	for i in range(0, inactive_bullets.size()):
		inactive_bullets[i].queue_free()
	
	var enemies = get_tree().get_root().get_child(0).get_node("Enemies").get_children()
	for i in range(0, enemies.size()):
		enemies[i].respawn()
	
	velocity = Vector2(0, 0)
	canShoot = true
	canPickup = true
	touching = []
	touchingCoins = []
	heldCoins = maxCoins
	position = currCheckpoint.position
	process_head()

func process_head():
	if heldCoins == 1:
		print(headCollider1.name)
		$RotationNode/PlayerHeadSprite.texture = head6
		headCollider1.set_deferred("disabled", false)
		headCollider2.set_deferred("disabled", true)
		headCollider3.set_deferred("disabled", true)
		headCollider4.set_deferred("disabled", true)
		headCollider5.set_deferred("disabled", true)
		headCollider6.set_deferred("disabled", true)
	elif heldCoins == 2:
		$RotationNode/PlayerHeadSprite.texture = head5
		headCollider1.set_deferred("disabled", true)
		headCollider2.set_deferred("disabled", false)
		headCollider3.set_deferred("disabled", true)
		headCollider4.set_deferred("disabled", true)
		headCollider5.set_deferred("disabled", true)
		headCollider6.set_deferred("disabled", true)
	elif heldCoins == 3:
		$RotationNode/PlayerHeadSprite.texture = head4
		headCollider1.set_deferred("disabled", true)
		headCollider2.set_deferred("disabled", true)
		headCollider3.set_deferred("disabled", false)
		headCollider4.set_deferred("disabled", true)
		headCollider5.set_deferred("disabled", true)
		headCollider6.set_deferred("disabled", true)
	elif heldCoins == 4:
		$RotationNode/PlayerHeadSprite.texture = head3
		headCollider1.set_deferred("disabled", true)
		headCollider2.set_deferred("disabled", true)
		headCollider3.set_deferred("disabled", true)
		headCollider4.set_deferred("disabled", false)
		headCollider5.set_deferred("disabled", true)
		headCollider6.set_deferred("disabled", true)
	elif heldCoins == 5:
		$RotationNode/PlayerHeadSprite.texture = head2
		headCollider1.set_deferred("disabled", true)
		headCollider2.set_deferred("disabled", true)
		headCollider3.set_deferred("disabled", true)
		headCollider4.set_deferred("disabled", true)
		headCollider5.set_deferred("disabled", false)
		headCollider6.set_deferred("disabled", true)
	elif heldCoins == 6:
		$RotationNode/PlayerHeadSprite.texture = head1
		headCollider1.set_deferred("disabled", true)
		headCollider2.set_deferred("disabled", true)
		headCollider3.set_deferred("disabled", true)
		headCollider4.set_deferred("disabled", true)
		headCollider5.set_deferred("disabled", true)
		headCollider6.set_deferred("disabled", false)
	else :
		$RotationNode/PlayerHeadSprite.texture = null
		headCollider1.set_deferred("disabled", true)
		headCollider2.set_deferred("disabled", true)
		headCollider3.set_deferred("disabled", true)
		headCollider4.set_deferred("disabled", true)
		headCollider5.set_deferred("disabled", true)
		headCollider6.set_deferred("disabled", true)

func check_respawn():
	if Input.is_action_just_pressed("player_respawn") and currCheckpoint != null:
		respawn()

func check_door():
	if touchingDoor and Input.is_action_just_pressed("ui_up"):
		emit_signal("door_activated")


















