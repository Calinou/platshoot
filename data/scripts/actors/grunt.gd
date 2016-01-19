extends RigidBody2D

const MAX_SPEED = 120 * 60

onready var velocity = Vector2(0, 0)

var death_particles_scene = preload("res://data/scenes/misc/death_particles.tscn")

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	velocity = get_linear_velocity()
	var player_pos = get_node("/root/Level/Player/Player").get_pos()
	var grunt_pos = get_pos()
	
	# TODO: Movement

func die():
	var death_particles = death_particles_scene.instance()
	death_particles.set_global_pos(get_node("CollisionShape2D").get_pos())
	add_child(death_particles)
	get_node("CollisionShape2D").set_trigger(true)
	get_node("AnimationPlayer").play("Die")
	print("Grunt killed")

func _on_AnimationPlayer_finished():
	queue_free()
