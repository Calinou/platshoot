# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node2D

var kill := false


func _physics_process(_delta: float) -> void:
	for body in get_node("RigidBody2D").get_colliding_bodies():
		# Bullets can't hit the player
		if body.get_name() != "Player":
			_on_Timer_timeout()
		if body.has_method("damage"):
			body.damage(25)
			_on_Timer_timeout()


func _on_Timer_timeout() -> void:
	# Actually kill the particle
	if kill:
		queue_free()
	# Only make it stop emitting
	else:
		get_node("Smoothing2D/CPUParticles2D").set_emitting(false)
		get_node("Smoothing2D/Light2D").set_enabled(false)
		get_node("Timer").set_wait_time(2)
		get_node("Timer").start()
		kill = true
