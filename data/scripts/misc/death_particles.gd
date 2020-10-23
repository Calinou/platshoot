# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Particles2D

func _on_Timer_timeout():
	queue_free()

