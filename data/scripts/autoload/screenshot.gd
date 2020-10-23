# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node

var screenshots_dir := OS.get_system_dir(OS.SYSTEM_DIR_PICTURES) + "/" + ProjectSettings.get_setting("application/config/name") as String


func _ready() -> void:
	# Make it possible to take screenshots while paused
	pause_mode = PAUSE_MODE_PROCESS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("take_screenshot"):
		var directory := Directory.new()
		directory.make_dir_recursive(screenshots_dir)

		get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
		var image := get_viewport().get_texture().get_data()

		# The viewport must be flipped to match the rendered window
		image.flip_y()

		get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ALWAYS)

		# Screenshot file name with ISO 8601-like date
		var datetime := OS.get_datetime()
		for key in datetime:
			datetime[key] = str(datetime[key]).pad_zeros(2)

		var screenshot_name := "/escape-space_{year}-{month}-{day}_{hour}.{minute}.{second}".format(datetime)

		var error := image.save_png(screenshots_dir + "/" + screenshot_name + ".png")

		if error != OK:
			push_error("Couldn't save screenshot.")
