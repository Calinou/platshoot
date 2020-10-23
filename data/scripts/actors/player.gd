# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node2D

# Maximal running speed
const MAX_SPEED = 275 * 60

# Jump speed (velocity set when jumping)
const JUMP_SPEED = 350 * 60

# Jetpack speed
const JETPACK_SPEED = 17.5 * 60

## Horizontal speed bonus when using jetpack (factor)
const JETPACK_BONUS = 1.15

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

	# Show HUD when player is in scene
	Game.show_hud()

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _physics_process(delta):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	# Increase time (shown on HUD)
	Game.time += delta

	if Game.health <= 0 and Game.status == Game.STATUS_ALIVE:
		die()
	# Change crosshair color depending on health, and ammo bar value depending on ammo
	if Game.health > 0:
		get_node("Crosshair").set_modulate(Color(1 - Game.health / 100.0, Game.health / 100.0, 0))
	else:
		get_node("Crosshair").set_visible(false)
	get_node("Crosshair/ProgressBar").set_value(Game.ammo)

	# Flip player sprite if the crosshair is at the right of the player (player faces right),
	# else don't flip it (player faces left)
	if get_node("Crosshair").get_position().x > get_node("Player").get_position().x:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		get_node("Player/Sprite").set_flip_h(true)
	else:
		get_node("Player/Sprite").set_flip_h(false)

	if Game.status == Game.STATUS_ALIVE:
		# Health regeneration (1 per second)
		if Game.health > 0:
			Game.health = min(Game.health + delta, 100)

		# Mouse position/offset computations (for gun and crosshair)
		offset = -get_viewport().get_canvas_transform().origin * get_node("Player/Camera2D").get_zoom() # Get the offset
		relative_mouse_pos = get_viewport().get_mouse_position() * get_node("Player/Camera2D").get_zoom() + offset # And add it to the mouse position  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		get_node("Player/Gun").look_at(relative_mouse_pos)
		# Move crosshair at mouse position
		get_node("Crosshair").set_position(relative_mouse_pos)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		# Current velocity
		velocity = get_node("Player").get_linear_velocity()

		# Moving left
		if Input.is_action_pressed("move_left"):
			speed = clamp(speed - MAX_SPEED * 4 * delta, -MAX_SPEED, MAX_SPEED)
			get_node("Player/AnimationPlayer").set_speed_scale(2)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

		# Moving right
		elif Input.is_action_pressed("move_right"):
			speed = clamp(speed + MAX_SPEED * 4 * delta, -MAX_SPEED, MAX_SPEED)
			get_node("Player/AnimationPlayer").set_speed_scale(2)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

		# Friction (when the player doesn't press any movement key)
		else:
			speed *= 0.925
			get_node("Player/AnimationPlayer").set_speed_scale(0)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

		# Set the new velocity
		get_node("Player").set_linear_velocity(Vector2(speed * delta, velocity.y))

		# Falling damage
		if velocity_new.y - velocity.y >= FALL_DAMAGE_THRESHOLD:
			damage((velocity_new.y - velocity.y - FALL_DAMAGE_THRESHOLD) / FALL_DAMAGE_FACTOR)

		# Jumping
		if Input.is_action_pressed("move_up") and is_touching_ground():
			get_node("Player").set_linear_velocity(Vector2(velocity.x, -JUMP_SPEED * delta))

		# Jetpack (uses fuel)
		if Input.is_action_pressed("jetpack") and Game.fuel > 0:
			get_node("Player").set_linear_velocity(Vector2(JETPACK_BONUS * speed * delta, velocity.y - JETPACK_SPEED * delta))
			Game.fuel = max(0, Game.fuel - 20 * delta)
			get_node("Player/JetpackParticles").set_emitting(true)

		# Firing weapons
		if Input.is_action_pressed("attack") and Game.ammo >= 1 and get_node("BulletTimer").get_time_left() == 0:
			var bullet = bullet_scene.instance()
			bullet.set_position(get_node("Player/Gun").get_global_position())  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			add_child(bullet)
			bullet.get_node("RigidBody2D").set_linear_velocity(Vector2(BULLET_SPEED, 0).rotated(get_node("Player/Gun").get_rotation() - deg2rad(BULLET_SPREAD / 2.0 + randf() * BULLET_SPREAD)))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			Sound.play(Sound.Type.NON_POSITIONAL, self, preload("res://data/sounds/pistol.wav"), -12, rand_range(0.95, 1.05))
			Game.ammo -= 1
			if Game.weapon == Game.WEAPON_PISTOL:
				get_node("BulletTimer").set_wait_time(BULLET_REFIRE)
			elif Game.weapon == Game.WEAPON_CHAINGUN:
				get_node("BulletTimer").set_wait_time(BULLET_REFIRE / 3)
			get_node("BulletTimer").start()
		elif Input.is_action_pressed("attack") and get_node("BulletTimer").get_time_left() == 0:
			Sound.play(Sound.Type.NON_POSITIONAL, self, preload("res://data/sounds/no_ammo.wav"), -12, rand_range(0.95, 1.05))
			if Game.weapon == Game.WEAPON_PISTOL:
				get_node("BulletTimer").set_wait_time(BULLET_REFIRE)
			elif Game.weapon == Game.WEAPON_CHAINGUN:
				get_node("BulletTimer").set_wait_time(BULLET_REFIRE / 3)
			get_node("BulletTimer").start()

		# Fuel regeneration
		if not Input.is_action_pressed("jetpack"):
			Game.fuel = min(100, Game.fuel + 6 * delta)
			# Disable jetpack particles
			get_node("Player/JetpackParticles").set_emitting(false)

		# Disable jetpack particles if having no fuel (even when pressing the key)
		if Game.fuel <= 1:
			get_node("Player/JetpackParticles").set_emitting(false)

		# Falling very fast kills the player
		if velocity.y >= 2000:
			damage(1000)

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
	if event.is_action_pressed("weapon_previous"):
		Game.weapon = wrapi(Game.weapon - 1, 1, 3)
	if event.is_action_pressed("weapon_next"):
		Game.weapon = wrapi(Game.weapon + 1, 1, 3)

	# Respawn when clicking, if dead, after a delay of 2.5 seconds
	if Game.status == Game.STATUS_DEAD and event.is_action_pressed("attack") and get_node("RespawnTimer").get_time_left() == 0:
		get_tree().change_scene("res://data/scenes/levels/" + str(Game.level_to_play) + ".tscn")

	# Suicide (default key: Ctrl+K)
	if event.is_action_pressed("suicide") and Game.status == Game.STATUS_ALIVE:
		damage(1000)

# Returns true if the player is touching ground
func is_touching_ground():
	return get_node("Player/RayCast2D").is_colliding()

func damage(points):
	# If player has armor, divide damage by half on health and deplete armor
	if Game.armor > 0:
		Game.armor = max(0, Game.armor - points / 2)
		Game.health = max(0, Game.health - points / 2)
	# If player has no armor, deplete health
	else:
		Game.health = max(0, Game.health - points)

	if Game.health <= 0:
		Sound.play(Sound.Type.NON_POSITIONAL, self, preload("res://data/sounds/player_death.wav"), 0.5, 1.15)
	else:
		Sound.play(Sound.Type.NON_POSITIONAL, self, preload("res://data/sounds/player_hurt.wav"), 0, rand_range(0.95, 1.05))

# Called when the player dies
func die():
	Game.status = Game.STATUS_DEAD
	get_node("RespawnTimer").set_wait_time(RESPAWN_DELAY)
	get_node("RespawnTimer").start()

# Called when the player respawns
func respawned():
	Game.health = 100.0
	Game.armor = 0
	Game.ammo = 25
	Game.weapon = Game.WEAPON_PISTOL
	Game.fuel = 100.0

	Game.time = 0.0
	Game.kills = 0
	Game.items = 0
	Game.credits = 0
	Game.status = Game.STATUS_ALIVE
