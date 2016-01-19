extends Node2D

# Maximal running speed
const MAX_SPEED = 250 * 60

# Jump speed (velocity set when jumping)
const JUMP_SPEED = 350 * 60

# Speed of bullets
const BULLET_SPEED = 1250

# Bullet inaccuracy (lower is more accurate)
const BULLET_SPREAD = 8

# Time in seconds between each bullet fire
const BULLET_REFIRE = 0.4

# Delay after dying required to wait before being allowed to respawn
const RESPAWN_DELAY = 2.5

# The speed at which higher falling speeds will deal damage to the player
const FALL_DAMAGE_THRESHOLD = 700

# Lower factors deal more damage
const FALL_DAMAGE_FACTOR = 6

onready var velocity = Vector2(0, 0)
onready var velocity_new = Vector2(0, 0)
onready var speed = 0
onready var bullet_scene = preload("res://data/scenes/misc/bullet.tscn")
onready var offset = Vector2(0, 0)
onready var relative_mouse_pos = Vector2(0, 0)

func _ready():
	# Set the number of enemies present in the level
	Game.kills_total = get_node("/root/Level/Enemies").get_child_count()

	# Set the number of items present in the level
	Game.items_total = get_node("/root/Level/Items").get_child_count()

	respawned()

	set_fixed_process(true)
	set_process_input(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _fixed_process(delta):
	# Increase time (shown on HUD)
	Game.time += delta

	if Game.health <= 0 and Game.status == Game.STATUS_ALIVE:
		die()
	# Change crosshair color depending on health, and ammo bar value depending on ammo
	if Game.health > 0:
		get_node("Crosshair").set_modulate(Color(1 - Game.health / 100.0, Game.health / 100.0, 0))
	else:
		get_node("Crosshair").set_modulate(Color(0, 0, 0))
	get_node("Crosshair/ProgressBar").set_value(Game.ammo)

	# Flip player sprite if the crosshair is at the right of the player (player faces right),
	# else don't flip it (player faces left)
	if get_node("Crosshair").get_pos().x > get_node("Player").get_pos().x:
		get_node("Player/Sprite").set_flip_h(true)
	else:
		get_node("Player/Sprite").set_flip_h(false)

	if Game.status == Game.STATUS_ALIVE:
		# Health regeneration (1 per second)
		if Game.health > 0:
			Game.health = min(Game.health + delta, 100)
	
		# Mouse position/offset computations (for gun and crosshair)
		offset = -get_viewport().get_canvas_transform().o * get_node("Player/Camera2D").get_zoom() # Get the offset
		relative_mouse_pos = get_viewport().get_mouse_pos() * get_node("Player/Camera2D").get_zoom() + offset # And add it to the mouse position
		get_node("Player/Gun").look_at(relative_mouse_pos)
		# Move crosshair at mouse position
		get_node("Crosshair").set_pos(relative_mouse_pos)
		# Current velocity
		velocity = get_node("Player").get_linear_velocity()
	
		# Moving left
		if Input.is_action_pressed("move_left"):
			speed = clamp(speed - MAX_SPEED * 4 * delta, -MAX_SPEED, MAX_SPEED)
			get_node("Player/AnimationPlayer").set_speed(1.6)
	
		# Moving right
		elif Input.is_action_pressed("move_right"):
			speed = clamp(speed + MAX_SPEED * 4 * delta, -MAX_SPEED, MAX_SPEED)
			get_node("Player/AnimationPlayer").set_speed(1.6)
		
		# Friction
		else:
			speed *= 0.925
			get_node("Player/AnimationPlayer").set_speed(0)
	
		# Set the new velocity
		get_node("Player").set_linear_velocity(Vector2(speed * delta, velocity.y))
		
		if velocity_new.y - velocity.y >= FALL_DAMAGE_THRESHOLD:
			damage((velocity_new.y - velocity.y - FALL_DAMAGE_THRESHOLD) / FALL_DAMAGE_FACTOR)
		
		# Jumping
		if Input.is_action_pressed("move_up") and is_touching_ground():
			get_node("Player").set_linear_velocity(Vector2(velocity.x, -JUMP_SPEED * delta))
	
		if Input.is_action_pressed("attack") and Game.ammo >= 1 and get_node("BulletTimer").get_time_left() == 0:
			var bullet = bullet_scene.instance()
			bullet.set_pos(get_node("Player/Gun").get_global_pos())
			add_child(bullet)
			bullet.get_node("RigidBody2D").set_linear_velocity(Vector2(BULLET_SPEED, 0).rotated(get_node("Player/Gun").get_rot() - deg2rad(90 - BULLET_SPREAD / 2 + randf() * BULLET_SPREAD)))
			get_node("Player/SamplePlayer2D").play("pistol")
			Game.ammo -= 1
			if Game.weapon == Game.WEAPON_PISTOL:
				get_node("BulletTimer").set_wait_time(BULLET_REFIRE)
			elif Game.weapon == Game.WEAPON_CHAINGUN:
				get_node("BulletTimer").set_wait_time(BULLET_REFIRE / 3)
			get_node("BulletTimer").start()
		elif Input.is_action_pressed("attack") and get_node("BulletTimer").get_time_left() == 0:
			get_node("Player/SamplePlayer2D").play("no_ammo")
			if Game.weapon == Game.WEAPON_PISTOL:
				get_node("BulletTimer").set_wait_time(BULLET_REFIRE)
			elif Game.weapon == Game.WEAPON_CHAINGUN:
				get_node("BulletTimer").set_wait_time(BULLET_REFIRE / 3)
			get_node("BulletTimer").start()
		
		velocity_new = get_node("Player").get_linear_velocity()

func _input(event):
	var zoom = get_node("Player/Camera2D").get_zoom().x
	if event.is_action_pressed("zoom_in"):
		get_node("Player/Camera2D").set_zoom(Vector2(max(0.25, zoom - 0.125), max(0.25, zoom - 0.125)))
	if event.is_action_pressed("zoom_out"):
		get_node("Player/Camera2D").set_zoom(Vector2(min(2, zoom + 0.125), min(2, zoom + 0.125)))
	if event.is_action_pressed("zoom_reset"):
		get_node("Player/Camera2D").set_zoom(Vector2(0.5, 0.5))
	
	# Change weapon
	if event.is_action("weapon_prev"):
		Game.weapon = clamp(Game.weapon - 1, 1, 2)
	if event.is_action("weapon_next"):
		Game.weapon = clamp(Game.weapon + 1, 1, 2)
	
	# Respawn when clicking, if dead, after a delay of 2.5 seconds
	if Game.status == Game.STATUS_DEAD and event.is_action_pressed("attack") and get_node("RespawnTimer").get_time_left() == 0:
		get_tree().change_scene("res://data/scenes/levels/1.tscn")
	
	# Suicide (default key: Ctrl+K)
	if event.is_action_pressed("suicide"):
		damage(1000)

# Returns true if the player is touching ground
func is_touching_ground():
	if get_node("Player/RayCast2D").is_colliding():
		return true
	else:
		return false

func damage(points):
	# If player has armor, divide damage by half on health and deplete armor
	if Game.armor > 0:
		Game.armor = max(0, Game.armor - points / 2)
		Game.health = max(0, Game.health - points / 2)
	# If player has no armor, deplete health
	else:
		Game.health = max(0, Game.health - points)
	
	if Game.health <= 0:
		get_node("Player/SamplePlayer2D").play("player_death")
	else:
		get_node("Player/SamplePlayer2D").play("player_hurt")

# Called when the player dies
func die():
	Game.status = Game.STATUS_DEAD
	get_node("RespawnTimer").set_wait_time(RESPAWN_DELAY)
	get_node("RespawnTimer").start()

# Called when the player respawns
func respawned():
	Game.health = 100
	Game.armor = 0
	Game.ammo = 25
	Game.weapon = Game.WEAPON_PISTOL
	
	Game.time = 0.0
	Game.kills = 0
	Game.items = 0
	Game.status = Game.STATUS_ALIVE