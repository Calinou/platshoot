# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends RigidBody2D

# Maximal movement speed
const MAX_SPEED = 140 * 60

# Minimum time between punches
const MELEE_REFIRE = 0.4

# Range above which grunts won't hunt the player
const AGGRO_RANGE = 320

# Number of credits given when killing a grunt
const GRUNT_KILL_CREDITS = 5

onready var velocity = Vector2(0, 0)
onready var hurt_player = false
# This variable is set to false when the monster dies, so that they can't
# damage the player
onready var dangerous = true

# The health each grunt has
onready var health = 75

var death_particles_scene = preload("res://data/scenes/misc/death_particles.tscn")

func _ready():
	# Desynchronize the animation of each grunt
	get_node("AnimationPlayer").seek(randf())

func _physics_process(delta):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	get_node("ProgressBar").set_value(health)
	velocity = get_linear_velocity()
	var player_pos = get_node("/root/Level/Player/Player").get_position()  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	var grunt_pos = get_position()  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

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

func damage(dmg):
	health -= dmg
	if health <= 0:
		die()
	else:
		pass
		#get_node("AudioStreamPlayer2D").play("player_hurt")  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func die():
	dangerous = false
	var death_particles = death_particles_scene.instance()
	death_particles.set_global_position(get_node("CollisionShape2D").get_position())  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	add_child(death_particles)
	get_node("CollisionShape2D").queue_free()
	Sound.play(Sound.Type.POSITIONAL_2D, self, preload("res://data/sounds/grunt_death.wav"), 3, rand_range(0.9, 1.05))
	get_node("AnimationPlayer").play("Die")

# Remove grunt after death animation
func _on_AnimationPlayer_finished():
	Game.kills += 1
	Game.credits += GRUNT_KILL_CREDITS
	queue_free()

func _on_Area2D_body_enter(body):
	if body.get_name() == "Player" and dangerous:
		hurt_player = true


func _on_Area2D_body_exit(body):
	if body.get_name() == "Player":
		hurt_player = false

