extends TileMap

# Higher number of iterations looks better, but is slower.
const ITERATIONS = 10

func _ready() -> void:
	# Create duplicate tilemap layers for a pseudo-3D look.
	for i in ITERATIONS:
		var canvas_layer = CanvasLayer.new()
		# Make the TileMap draw in front of the background but behind the HUD and entities.
		canvas_layer.layer = -1
		canvas_layer.follow_viewport_enable = 1
		canvas_layer.follow_viewport_scale = 0.875 + i * 0.0125
		canvas_layer.add_child(duplicate(0))
		get_parent().call_deferred("add_child", canvas_layer)
