extends Node2D

const MAX_SPEED = 200 * 60
const JUMP_SPEED = 320 * 60
const BULLET_SPEED = 1000
const BULLET_REFIRE = 0.2

onready var velocity = Vector2(0, 0)
onready var velocity_new = Vector2(0, 0)
onready var speed = 0
onready var bullet_scene = preload("res://data/scenes/misc/bullet.tscn")
onready var offset = Vector2(0, 0)
onready var relative_mouse_pos = Vector2(0, 0)

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _fixed_process(delta):
	# Change crosshair color depending on health
	get_node("Crosshair").set_modulate(Color(1 - Game.health / 100.0, Game.health / 100.0, 0))
	get_node("Crosshair/ProgressBar").set_value(Game.ammo)

	# Flip player sprite if the crosshair is at the right of the player (player faces right),
	# else don't flip it (player faces left)
	if get_node("Crosshair").get_pos().x > get_node("Player").get_pos().x:
		get_node("Player/Sprite").set_flip_h(true)
	else:
		get_node("Player/Sprite").set_flip_h(false)

	# Health regeneration (1 per second)
	if Game.health > 0:
		Game.health = min(Game.health + delta, 100)

	# Mouse position/offset computations (for gun and crosshair)
	offset = -get_viewport().get_canvas_transform().o # Get the offset
	relative_mouse_pos = get_viewport().get_mouse_pos() + offset # And add it to the mouse position
	get_node("Player/Gun").look_at(relative_mouse_pos)
	# Move crosshair at mouse position
	get_node("Crosshair").set_pos(relative_mouse_pos)
	# Current velocity
	velocity = get_node("Player").get_linear_velocity()

	# Moving left
	if Input.is_action_pressed("move_left"):
		speed = clamp(speed - MAX_SPEED * 4 * delta, -MAX_SPEED, MAX_SPEED)
		get_node("Player/AnimationPlayer").set_speed(1.5)

	# Moving right
	elif Input.is_action_pressed("move_right"):
		speed = clamp(speed + MAX_SPEED * 4 * delta, -MAX_SPEED, MAX_SPEED)
		get_node("Player/AnimationPlayer").set_speed(1.5)
	
	# Friction
	else:
		speed *= 0.925
		get_node("Player/AnimationPlayer").set_speed(0)

	# Set the new velocity
	get_node("Player").set_linear_velocity(Vector2(speed * delta, velocity.y))
	
	if velocity_new.y - velocity.y >= 600:
		damage((velocity_new.y - velocity.y - 600) / 10)
	
	# Jumping
	if Input.is_action_pressed("move_up") and is_touching_ground():
		get_node("Player").set_linear_velocity(Vector2(velocity.x, -JUMP_SPEED * delta))

	if Input.is_action_pressed("attack") and Game.ammo >= 1 and get_node("BulletTimer").get_time_left() == 0:
		var bullet = bullet_scene.instance()
		bullet.set_pos(get_node("Player/Gun").get_global_pos())
		add_child(bullet)
		bullet.get_node("RigidBody2D").set_linear_velocity(Vector2(BULLET_SPEED, 0).rotated(get_node("Player/Gun").get_rot() - deg2rad(90)))
		get_node("Player/SamplePlayer2D").play("pistol")
		Game.ammo -= 1
		get_node("BulletTimer").set_wait_time(BULLET_REFIRE)
		get_node("BulletTimer").start()
	elif Input.is_action_pressed("attack") and get_node("BulletTimer").get_time_left() == 0:
		get_node("Player/SamplePlayer2D").play("no_ammo")
		get_node("BulletTimer").set_wait_time(BULLET_REFIRE)
		get_node("BulletTimer").start()
	
	velocity_new = get_node("Player").get_linear_velocity()

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