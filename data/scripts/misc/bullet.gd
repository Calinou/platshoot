extends Node2D

var kill = false

func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	for body in get_node("RigidBody2D").get_colliding_bodies():
		# Bullets can't hit the player
		if body.get_name() != "Player":
			_on_Timer_timeout()
		if body.has_method("die"):
			body.die()
			_on_Timer_timeout()

func _on_Timer_timeout():
	# Actually kill the particle
	if kill:
		queue_free()
	# Only make it stop emitting
	else:
		get_node("RigidBody2D/Particles2D").set_emitting(false)
		get_node("RigidBody2D/Light2D").set_enabled(false)
		get_node("Timer").set_wait_time(2)
		get_node("Timer").start()
		kill = true