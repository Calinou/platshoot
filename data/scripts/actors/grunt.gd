# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends RigidBody2D

# Maximal movement speed.
const MAX_SPEED = 140 * 60

# Minimum time between punches.
const MELEE_REFIRE = 0.4

# Range above which grunts won't hunt the player.
const AGGRO_RANGE = 320

onready var velocity := Vector2(0, 0)
onready var hurt_player := false
# This variable is set to false when the monster dies, so that they can't
# damage the player.
onready var dangerous := true

# The health each grunt has.
onready var health := 75

const death_particles_scene := preload("res://data/scenes/misc/death_particles.tscn")


func _ready() -> void:
	# Desynchronize the animation of each grunt.
	$AnimationPlayer.seek(randf())


func _physics_process(delta: float) -> void:
	# TODO: Reimplement player chasing to work with multiple players.
	return

	$ProgressBar.value = health
	var player_pos: Vector2 = $"/root/Level/Players/1".position

	if hurt_player:
		if is_zero_approx($Timer.time_left) and Game.health > 0:
			$"/root/Level/Players/1".rpc("damage", 15)
			$Timer.wait_time = MELEE_REFIRE
			$Timer.start()

	# Move the grunt according to X position of player (difference).
	# If the player is at the left, move the grunt towards the left.
	# Else, move the grunt towards the right.
	var difference := position.x - player_pos.x
	# If the grunt is outside of the aggro range, don't change movement.
	if abs(difference) >= AGGRO_RANGE:
		return
	if difference > 0:
		linear_velocity = Vector2(-MAX_SPEED * delta, linear_velocity.y)
		$"Smoothing2D/Sprite".flip_h = false
	else:
		linear_velocity = Vector2(MAX_SPEED * delta, linear_velocity.y)
		$"Smoothing2D/Sprite".flip_h = true


func damage(dmg: int) -> void:
	health -= dmg
	if health <= 0:
		die()
	else:
		Sound.play(Sound.Type.POSITIONAL_2D, self, preload("res://data/sounds/player_hurt.wav"), 3, rand_range(0.9, 1.05))


func die() -> void:
	dangerous = false
	var death_particles := death_particles_scene.instance()
	death_particles.global_position = $CollisionShape2D.position
	add_child(death_particles)
	$CollisionShape2D.queue_free()
	Sound.play(Sound.Type.POSITIONAL_2D, self, preload("res://data/sounds/grunt_death.wav"), 3, rand_range(0.9, 1.05))
	$AnimationPlayer.play("Die")
	Statistics.enemies_killed += 1


# Remove grunt after death animation.
func _on_AnimationPlayer_finished(_anim_name: String) -> void:
	Game.kills += 1
	queue_free()


func _on_Area2D_body_enter(body: Node2D) -> void:
	if body.name == "Player" and dangerous:
		hurt_player = true


func _on_Area2D_body_exit(body: Node2D) -> void:
	if body.name == "Player":
		hurt_player = false
