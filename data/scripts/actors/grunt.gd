extends RigidBody2D

const MAX_SPEED = 140 * 60
const MELEE_REFIRE = 0.4
const AGGRO_RANGE = 320

onready var velocity = Vector2(0, 0)
onready var hurt_player = false
# This variable is set to false when the monster dies, so that they can't
# damage the player
onready var dangerous = true

var death_particles_scene = preload("res://data/scenes/misc/death_particles.tscn")

func _ready():
	# Desynchronize the animation of each grunt
	get_node("AnimationPlayer").seek(randf())
	set_fixed_process(true)

func _fixed_process(delta):
	velocity = get_linear_velocity()
	var player_pos = get_node("/root/Level/Player/Player").get_pos()
	var grunt_pos = get_pos()

	if hurt_player:
		if get_node("Timer").get_time_left() == 0 and Game.health > 0:
			get_node("/root/Level/Player").damage(15)
			get_node("Timer").set_wait_time(MELEE_REFIRE)
			get_node("Timer").start()

	# Move the grunt according to X position of player (difference)
	# If the player is at the left, move the grunt towards the left
	# Else, move the grunt towards the right
	var difference = grunt_pos.x - player_pos.x
	# If the grunt is outside of the aggro range, don't change movement
	if abs(difference) >= AGGRO_RANGE:
		return
	if difference > 0:
		set_linear_velocity(Vector2(-MAX_SPEED * delta, velocity.y))
		get_node("Sprite").set_flip_h(false)
	else:
		set_linear_velocity(Vector2(MAX_SPEED * delta, velocity.y))
		get_node("Sprite").set_flip_h(true)

func die():
	dangerous = false
	var death_particles = death_particles_scene.instance()
	death_particles.set_global_pos(get_node("CollisionShape2D").get_pos())
	add_child(death_particles)
	get_node("CollisionShape2D").set_trigger(true)
	get_node("SamplePlayer2D").play("grunt_death")
	get_node("AnimationPlayer").play("Die")

func _on_AnimationPlayer_finished():
	queue_free()


func _on_Area2D_body_enter(body):
	if body.get_name() == "Player" and dangerous:
		hurt_player = true


func _on_Area2D_body_exit(body):
	if body.get_name() == "Player":
		hurt_player = false
