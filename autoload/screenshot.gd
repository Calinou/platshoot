# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node

var screenshots_dir := OS.get_system_dir(OS.SYSTEM_DIR_PICTURES) + "/" + ProjectSettings.get_setting("application/config/name") as String


func _ready() -> void:
	# Make it possible to take screenshots while paused.
	process_mode = PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("take_screenshot"):
		DirAccess.make_dir_recursive_absolute(screenshots_dir)

		get_viewport().set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
		var image := get_viewport().get_texture().get_image()

		get_viewport().set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)

		# Screenshot file name with ISO 8601-like date.
		var datetime := Time.get_datetime_dict_from_system()
		for key in datetime:
			datetime[key] = str(datetime[key]).pad_zeros(2)

		var screenshot_name := "/escape-space_{year}-{month}-{day}_{hour}.{minute}.{second}".format(datetime)

		var error := image.save_png(screenshots_dir + "/" + screenshot_name + ".png")

		if error != OK:
			push_error("Couldn't save screenshot.")
