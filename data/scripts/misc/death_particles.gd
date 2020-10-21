# Copyright (c) 2016 Calinou and contributors
# Licensed under the MIT license, see `LICENSE.md` for more information.

extends Particles2D

func _on_Timer_timeout():
	queue_free()

