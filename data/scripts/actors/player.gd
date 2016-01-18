extends Node2D

const MAX_SPEED = 200 * 60
const JUMP_SPEED = 320 * 60
const SPRINT_FACTOR = 1.5
const BULLET_SPEED = 1000
const BULLET_REFIRE = 0.21

onready var velocity = Vector2(0, 0)
onready var speed = 0
onready var bullet_scene = preload("res://data/scenes/misc/bullet.tscn")
onready var offset = Vector2(0, 0)
onready var relative_mouse_pos = Vector2(0, 0)

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _fixed_process(delta):
	offset = -get_viewport().get_canvas_transform().o # Get the offset
	relative_mouse_pos = get_viewport().get_mouse_pos() + offset # And add it to the mouse position
	get_node("Player/Gun").look_at(relative_mouse_pos)
	# Move crosshair at mouse position
	get_node("Crosshair").set_pos(relative_mouse_pos)
	# Current velocity
	velocity = get_node("Player").get_linear_velocity()

	# Moving left
	if Input.is_action_pressed("move_left"):
		speed = clamp(speed - MAX_SPEED * 4 * delta, -MAX_SPEED * sprinting(), MAX_SPEED * sprinting())
		# If sprinting, deplete stamina
		if sprinting() != 1.0:
			Game.stamina -= 8.0 * delta

	# Moving right
	elif Input.is_action_pressed("move_right"):
		speed = clamp(speed + MAX_SPEED * 4 * delta, -MAX_SPEED * sprinting(), MAX_SPEED * sprinting())
		# If sprinting, deplete stamina
		if sprinting() != 1.0:
			Game.stamina -= 8.0 * delta
	
	# Friction
	else:
		speed *= 0.925
		if is_touching_ground():
			Game.stamina += 5.0 * delta

	# Set the new velocity
	get_node("Player").set_linear_velocity(Vector2(speed * delta, velocity.y))
	
	# Jumping
	if Input.is_action_pressed("move_up") and is_touching_ground() and Game.stamina > 0:
		get_node("Player").set_linear_velocity(Vector2(velocity.x, -JUMP_SPEED * delta))
		Game.stamina -= 100.0 * delta

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

# Returns the sprint factor if the player is sprinting
func sprinting():
	if Input.is_action_pressed("move_speed") and Game.stamina > 0:
		return SPRINT_FACTOR
	else:
		return 1.0

# Returns true if the player is touching ground
func is_touching_ground():
	if get_node("Player/RayCast2D").is_colliding():
		return true
	else:
		return false