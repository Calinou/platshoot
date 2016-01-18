extends Node2D

const MAX_SPEED = 200 * 60
const JUMP_SPEED = 240 * 60
const SPRINT_FACTOR = 1.5

onready var velocity = Vector2(0, 0)
onready var speed = 0
onready var bullet_scene = preload("res://data/scenes/misc/bullet.tscn")

func _ready():
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	get_node("RigidBody2D/Gun").look_at(get_viewport().get_mouse_pos())
	# Current velocity
	velocity = get_node("RigidBody2D").get_linear_velocity()

	# Moving left
	if Input.is_action_pressed("move_left"):
		speed = -MAX_SPEED

	# Moving right
	elif Input.is_action_pressed("move_right"):
		speed = MAX_SPEED
	
	# Friction
	else:
		speed *= 0.9

	# Sprinting
	if is_sprinting() and is_move_key_pressed():
		speed *= 1.3

	# Set the new velocity
	get_node("RigidBody2D").set_linear_velocity(Vector2(speed * delta, velocity.y))
	
	# Jumping
	if Input.is_action_pressed("move_up") and is_touching_ground():
		get_node("RigidBody2D").set_linear_velocity(Vector2(velocity.x, -JUMP_SPEED * delta))

func _input(event):
	if event.is_action_pressed("attack"):
		var bullet = bullet_scene.instance()
		add_child(bullet)
		bullet.set_pos(get_node("RigidBody2D").get_pos())
		bullet.get_node("RigidBody2D").set_linear_velocity(Vector2(300, 0).rotated(deg2rad(get_node("RigidBody2D/Gun").get_rot())))

# Returns true if the player is pressing a movement key
func is_move_key_pressed():
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		return true
	else:
		return false

# Returns true if the player is sprinting
func is_sprinting():
	if Input.is_action_pressed("move_speed"):
		return true
	else:
		return false

# Returns true if the player is touching ground
func is_touching_ground():
	if get_node("RigidBody2D/RayCast2D").is_colliding():
		return true
	else:
		return false