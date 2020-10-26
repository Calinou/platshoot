# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node2D

var kill := false


func _physics_process(_delta: float) -> void:
	for body in $RigidBody2D.get_colliding_bodies():
		# Bullets can't hit the player
		if body.name != "Player":
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
		$"Smoothing2D/CPUParticles2D".emitting = false
		$"Smoothing2D/Light2D".enabled = false
		$Timer.wait_time = 2
		$Timer.start()
		kill = true
