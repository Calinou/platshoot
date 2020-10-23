# Copyright (c) 2016 Calinou and contributors
# Licensed under the MIT license, see `LICENSE.md` for more information.

extends Node2D

var kill = false

func _physics_process(delta):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	for body in get_node("RigidBody2D").get_colliding_bodies():
		# Bullets can't hit the player
		if body.get_name() != "Player":
			_on_Timer_timeout()
		if body.has_method("damage"):
			body.damage(25)
			_on_Timer_timeout()

func _on_Timer_timeout():
	# Actually kill the particle
	if kill:
		queue_free()
	# Only make it stop emitting
	else:
		get_node("RigidBody2D/CPUParticles2D").set_emitting(false)
		get_node("RigidBody2D/Light2D").set_enabled(false)
		get_node("Timer").set_wait_time(2)
		get_node("Timer").start()
		kill = true
