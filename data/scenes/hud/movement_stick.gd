# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
#
# Virtual movement stick for mobile gameplay which emulates a gamepad stick.

extends TextureRect

@onready var stick := $MovementStick as TextureRect


func _ready() -> void:
	# Hide the movement stick if there's no touchscreen.
	visible = DisplayServer.is_touchscreen_available()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		# Required to prevent the player from going left even if
		# they dragged their stick towards the right before releasing it.
		reset_input()

		stick.position = event.position - stick.size * stick.scale * 0.5

		# Create an action and simulate it immediately.
		var action := InputEventAction.new()
		var strength := clampf(remap(stick.position.x - 128, -128, 128, -1, 1), -1, 1)
		action.action = "move_left" if strength < 0.0 else "move_right"
		action.button_pressed = event is InputEventScreenDrag or event.is_pressed()
		action.strength = abs(strength)

		Input.parse_input_event(action)

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if not touch.is_pressed():
			# Center the stick again and reset input.
			stick.position = size * 0.5 - Vector2.ONE * stick.size * stick.scale * 0.5
			reset_input()


# Clear existing movement inputs.
func reset_input() -> void:
	var action := InputEventAction.new()
	action.action = "move_right"
	Input.parse_input_event(action)
	action.action = "move_left"
	Input.parse_input_event(action)
