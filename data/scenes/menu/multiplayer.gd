extends Control

signal back_pressed


func _on_back_pressed() -> void:
	emit_signal("back_pressed")
	visible = false
