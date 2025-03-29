extends Control

signal back_pressed

@onready var tree := $VBoxContainer/Tree as Tree


func _ready() -> void:
	# Create a dummy room item as it will be hidden.
	tree.create_item()

	for stat in Statistics.STATISTICS:
		var tree_item := tree.create_item()
		tree_item.set_text(0, stat.capitalize())
		tree_item.set_text(1, str(Statistics.get(stat)))


func _on_back_pressed() -> void:
	emit_signal("back_pressed")
	visible = false
