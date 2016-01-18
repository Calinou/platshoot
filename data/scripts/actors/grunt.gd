extends RigidBody2D

const MAX_SPEED = 120 * 60

onready var velocity = Vector2(0, 0)

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	velocity = get_linear_velocity()
	var player_pos = get_node("/root/Level/Player/Player").get_pos()
	var grunt_pos = get_pos()
	
	# TODO: Movement

func die():
	queue_free()
	print("Grunt killed")