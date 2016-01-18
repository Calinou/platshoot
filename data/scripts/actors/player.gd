extends Node2D

const MAX_SPEED = 200 * 60
const JUMP_SPEED = 320 * 60
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
		speed = clamp(speed - MAX_SPEED * 4 * delta, -MAX_SPEED * sprinting(), MAX_SPEED * sprinting())

	# Moving right
	elif Input.is_action_pressed("move_right"):
		speed = clamp(speed + MAX_SPEED * 4 * delta, -MAX_SPEED * sprinting(), MAX_SPEED * sprinting())
	
	# Friction
	else:
		speed *= 0.925

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
func sprinting():
	if Input.is_action_pressed("move_speed"):
		return SPRINT_FACTOR
	else:
		return 1.0

# Returns true if the player is touching ground
func is_touching_ground():
	if get_node("RigidBody2D/RayCast2D").is_colliding():
		return true
	else:
		return false