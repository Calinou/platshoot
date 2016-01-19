extends RigidBody2D

const MAX_SPEED = 120 * 60
const MELEE_REFIRE = 0.4

onready var velocity = Vector2(0, 0)
onready var hurt_player = false

var death_particles_scene = preload("res://data/scenes/misc/death_particles.tscn")

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	velocity = get_linear_velocity()
	var player_pos = get_node("/root/Level/Player/Player").get_pos()
	var grunt_pos = get_pos()

	if hurt_player:
		if get_node("Timer").get_time_left() == 0:
			get_node("/root/Level/Player").damage(15)
			get_node("Timer").set_wait_time(MELEE_REFIRE)
			get_node("Timer").start()

	# TODO: Movement

func die():
	var death_particles = death_particles_scene.instance()
	death_particles.set_global_pos(get_node("CollisionShape2D").get_pos())
	add_child(death_particles)
	get_node("CollisionShape2D").set_trigger(true)
	get_node("AnimationPlayer").play("Die")

func _on_AnimationPlayer_finished():
	queue_free()


func _on_Area2D_body_enter(body):
	if body.get_name() == "Player":
		hurt_player = true


func _on_Area2D_body_exit(body):
	if body.get_name() == "Player":
		hurt_player = false
