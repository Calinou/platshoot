# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node

const CONFIG_PATH = "user://stats.ini"

var config := ConfigFile.new()

# List of property names for statistics.
# The names displayed in the Statistics menu will be capitalized automatically.
const STATISTICS = [
	"enemies_killed",
	"times_died",
	"items_picked_up",
	"bullets_fired",
	"distance_travelled",
]

var enemies_killed := 0
var times_died := 0
var items_picked_up := 0
var bullets_fired := 0
var distance_travelled := 0


func _ready() -> void:
	config.load(CONFIG_PATH)

	# Load statistics dynamically.
	for stat in STATISTICS:
		set(stat, config.get_value("stats", stat, get(stat)))


func _exit_tree() -> void:
	# Save statistics dynamically.
	for stat in STATISTICS:
		config.set_value("stats", stat, get(stat))

	config.save(CONFIG_PATH)
