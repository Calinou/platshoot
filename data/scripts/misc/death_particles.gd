# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends GPUParticles2D


func _on_Timer_timeout() -> void:
	queue_free()
