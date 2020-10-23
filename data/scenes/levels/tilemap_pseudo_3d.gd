# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends TileMap

# Higher number of iterations looks better, but is slower.
const ITERATIONS = 10

func _ready() -> void:
	# Create duplicate tilemap layers for a pseudo-3D look.
	for i in ITERATIONS:
		var canvas_layer := CanvasLayer.new()
		# Make the TileMap draw in front of the background but behind the HUD and entities.
		canvas_layer.layer = -1
		canvas_layer.follow_viewport_enable = 1
		canvas_layer.follow_viewport_scale = 0.875 + int(i) * 0.0125
		var tilemap := duplicate(0)
		# Fade distant tilemaps to add a basic shading/fake contrast effect.
		var brightness := 0.5 + int(i) * 0.03
		tilemap.modulate = Color(brightness, brightness, brightness)
		canvas_layer.add_child(tilemap)
		get_parent().call_deferred("add_child", canvas_layer)
