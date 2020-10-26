# Copyright © 2016-2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node2D

# Maximum per-frame acceleration when running.
const ACCELERATION = 3000 * 60

# Jump speed (velocity set when jumping)
const JUMP_SPEED = 350 * 60

# Jetpack speed
const JETPACK_SPEED = 17.5 * 60

## Horizontal speed bonus when using jetpack (factor)
const JETPACK_BONUS = 1.15

# Speed of bullets
const BULLET_SPEED = 1250

# Bullet inaccuracy (lower is more accurate)
const BULLET_SPREAD = 8

# Time in seconds between each bullet fire
const BULLET_REFIRE = 0.4

# Delay after dying required to wait before being allowed to respawn
const RESPAWN_DELAY = 2.5

# The speed at which higher falling speeds will deal damage to the player
const FALL_DAMAGE_THRESHOLD = 700

# Lower factors deal more damage
const FALL_DAMAGE_FACTOR = 6

const BULLET_SCENE := preload("res://data/scenes/misc/bullet.tscn")

# Using a timer for double-tap shooting fixes issues related to "lingering" input
# while allowing full-auto shooting. I don't know why.
var double_tap_shoot_timer := 0.0

remotesync var player_position := Vector2.ZERO
remotesync var player_linear_velocity := Vector2.ZERO
remotesync var using_jetpack := false
remotesync var crosshair_position := Vector2.ZERO

var velocity := Vector2(0, 0)
var velocity_new := Vector2(0, 0)
var speed := 0.0
var offset := Vector2(0, 0)
var relative_mouse_pos := Vector2(0, 0)
onready var player := $Player as RigidBody2D
onready var camera := $Player/Camera2D as Camera2D
onready var default_zoom := camera.zoom
onready var crosshair := $Crosshair as Sprite
onready var player_sprite := $Smoothing2D/Sprite as Sprite
onready var preloader := $ResourcePreloader as ResourcePreloader
onready var animation_player := $Player/AnimationPlayer as AnimationPlayer
onready var crosshair_color_gradient := preloader.get_resource("crosshair_color_gradient") as Gradient
onready var sprite_base_offset := player_sprite.position.y


func _ready() -> void:
	set_process_input(is_network_master())
	player_position = player.position

	# Make our camera active, but not other players'
	camera.current = is_network_master()
	crosshair.visible = is_network_master()

	if not is_network_master():
		# Distinguish other players to avoid confusing them with our player.
		player_sprite.modulate = Color(0.8, 1.2, 1.4)

	# Set the number of enemies present in the level
	Game.kills_total = $"/root/Level/Enemies".get_child_count()

	# Set the number of items present in the level
	Game.items_total = $"/root/Level/Items".get_child_count()

	respawned()

	# Show HUD when player is in scene
	Game.show_hud()

	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	hide_hardware_mouse_cursor()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			call_deferred("hide_hardware_mouse_cursor")


func hide_hardware_mouse_cursor() -> void:
	if not is_network_master():
		return

	# Revert back to the default cursor. This is required; otherwise, the cursor will only change once.
	# (Only tested on Linux.)
	Input.set_custom_mouse_cursor(null)
	# Use a transparent cursor texture to hide the hardware cursor.
	Input.set_custom_mouse_cursor(preload("res://data/textures/transparent.png"))


func _process(delta) -> void:
	if is_network_master():
		double_tap_shoot_timer += delta
		# Mouse position/offset computations (for gun and crosshair)
		offset = -get_viewport().get_canvas_transform().origin * $"Player/Camera2D".zoom  # Get the offset
		relative_mouse_pos = get_viewport().get_mouse_position() * $"Player/Camera2D".zoom + offset  # And add it to the mouse position
		$"Player/Gun".look_at(relative_mouse_pos)
		# Move crosshair at mouse position
		crosshair.position = relative_mouse_pos

	# Add bobbing to the player sprite when moving and not airborne.
	if is_touching_ground():
		player_sprite.position.y = sprite_base_offset - abs(sin(OS.get_ticks_msec() * 0.01) * player_linear_velocity.x * 0.024)


func _physics_process(delta) -> void:
	if animation_player.current_animation == "walk":
		# Don't change the animation speed if currently displaying a shoot or pain animation.
		animation_player.playback_speed = min(abs(player_linear_velocity.x) * 0.009, 2.1)

	# Flip player sprite if the crosshair is at the right of the player (player faces right),
	# else don't flip it (player faces left).
	$"Smoothing2D/Sprite".flip_h = crosshair_position.x > player.position.x

	$"Player/JetpackParticles".emitting = using_jetpack

	if is_network_master():
		# Move the camera to partially follow the crosshair.
		# This helps the player get a better view on their surroundings.
		camera.global_position = lerp(player.global_position, crosshair.global_position, 0.25)

		# Increase time (shown on HUD)
		Game.time += delta

		if Game.health <= 0 and Game.status == Game.STATUS_ALIVE:
			die()

		# Change crosshair color depending on health, and ammo bar value depending on ammo.
		# This helps the player see their status immediately without having to look at the HUD
		# every so often.
		if Game.health > 0:
			$Crosshair.modulate = crosshair_color_gradient.interpolate(Game.health / 100.0)
		else:
			$Crosshair.visible = false
		$"Crosshair/ProgressBar".value = Game.ammo

		if Game.status == Game.STATUS_ALIVE:
			# Health regeneration (1 per second)
			if Game.health > 0:
				Game.health = min(Game.health + delta, 100)

			velocity = player.linear_velocity

			var movement := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
			speed += ACCELERATION * movement * delta
			# Apply Doom-style constant friction.
			speed *= 0.85

			# Set the new velocity.
			player.linear_velocity = Vector2(speed * delta, velocity.y)

			if velocity_new.y - velocity.y >= FALL_DAMAGE_THRESHOLD:
				# Apply falling damage.
				rpc("damage", (velocity_new.y - velocity.y - FALL_DAMAGE_THRESHOLD) / FALL_DAMAGE_FACTOR)

			if Input.is_action_pressed("move_up") and is_touching_ground():
				# Jump.
				player.linear_velocity = Vector2(velocity.x, -JUMP_SPEED * delta)

			# Jetpack (uses fuel).
			if Input.is_action_pressed("jetpack") and Game.fuel > 0:
				# Jump automatically if the player can jump.
				# This way, the player can benefit from the jetpack more.
				if is_touching_ground():
					player.linear_velocity = Vector2(velocity.x, -JUMP_SPEED * delta)
				else:
					player.linear_velocity = Vector2(JETPACK_BONUS * speed * delta, velocity.y - JETPACK_SPEED * delta)
					Game.fuel = max(0, Game.fuel - 50 * delta)
					rset("using_jetpack", true)

			# Fuel regeneration.
			if not Input.is_action_pressed("jetpack"):
				Game.fuel = min(100, Game.fuel + 6 * delta)
				rset("using_jetpack", false)

			# Disable jetpack particles if having no fuel (even when pressing the key).
			if Game.fuel <= 1:
				rset("using_jetpack", false)

			# Firing weapons.
			if Input.is_action_pressed("attack") and Game.ammo >= 1 and is_zero_approx($BulletTimer.time_left):
				var bullet_position: Vector2 = $"Player/Gun".global_position
				var bullet_velocity := Vector2(BULLET_SPEED, 0).rotated(get_node("Player/Gun").rotation - deg2rad(BULLET_SPREAD / 2.0 + randf() * BULLET_SPREAD))
				rpc("fire_bullet", bullet_position, bullet_velocity)

			elif Input.is_action_pressed("attack") and is_zero_approx($"BulletTimer".time_left):
				Sound.play(Sound.Type.NON_POSITIONAL, self, preload("res://data/sounds/no_ammo.wav"), -12, rand_range(0.95, 1.05))
				if Game.weapon == Game.WEAPON_PISTOL:
					$BulletTimer.wait_time = BULLET_REFIRE
				elif Game.weapon == Game.WEAPON_CHAINGUN:
					$BulletTimer.wait_time = BULLET_REFIRE / 3.0
				$BulletTimer.start()

			# Falling at a very high speed kills the player.
			if velocity.y >= 2000:
				rpc("damage", 1000)

			velocity_new = player.linear_velocity

			# Synchronize my player's position and velocity to other players.
			# The velocity is used for animating other players.
			rset_unreliable("player_position", player.position)
			rset_unreliable("player_linear_velocity", player.linear_velocity)
			# Synchronize crosshair postion so that player sprite flipping can also be synchronized.
			rset("crosshair_position", crosshair.position)
	else:
		player.position = player_position
		crosshair.position = crosshair_position

remotesync func fire_bullet(bullet_position: Vector2, bullet_velocity: Vector2) -> void:
	var remote_animation_player := get_node("/root/Level/Players/%d/Player/AnimationPlayer" % get_tree().get_rpc_sender_id())
	remote_animation_player.play("shoot")
	remote_animation_player.playback_speed = 1

	# Bullet will be owned by the server.
	var bullet := BULLET_SCENE.instance()
	bullet.position = bullet_position
	add_child(bullet)
	bullet.get_node("RigidBody2D").linear_velocity = bullet_velocity

	# Play the sound positionally only when it's our client firing.
	# This prevents the sound from being located in only one of the player's ears.
	Sound.play(
			Sound.Type.NON_POSITIONAL if is_network_master() else Sound.Type.POSITIONAL_2D,
			self,
			preload("res://data/sounds/pistol.wav"),
			-12,
			rand_range(0.95, 1.05)
	)

	if is_network_master():
		Game.ammo -= 1
		if Game.weapon == Game.WEAPON_PISTOL:
			$BulletTimer.wait_time = BULLET_REFIRE
		elif Game.weapon == Game.WEAPON_CHAINGUN:
			$BulletTimer.wait_time = BULLET_REFIRE / 3
		$BulletTimer.start()

func _input(event) -> void:
	# Input processing is disabled for non-master players.

	if OS.has_touchscreen_ui_hint() and event is InputEventMouseButton:
		# Double-tap to attack.
		var mb := event as InputEventMouseButton
		if mb.doubleclick:
			var action := InputEventAction.new()
			action.action = "attack"
			action.pressed = true
			Input.parse_input_event(action)
			double_tap_shoot_timer = 0.0

		if not mb.pressed and double_tap_shoot_timer > 0.0:
			# Release the attack.
			var action := InputEventAction.new()
			action.action = "attack"
			Input.parse_input_event(action)

	var zoom: float = $"Player/Camera2D".zoom.x
	if event.is_action_pressed("zoom_in"):
		$"Player/Camera2D".zoom = Vector2.ONE * max(0.25, zoom - 0.125)
	if event.is_action_pressed("zoom_out"):
		$"Player/Camera2D".zoom = Vector2.ONE * min(2, zoom + 0.125)
	if event.is_action_pressed("zoom_reset"):
		$"Player/Camera2D".zoom = Vector2.ONE * default_zoom.x

	if event.is_action_pressed("weapon_previous"):
		Game.weapon = wrapi(Game.weapon - 1, 1, 3)
	if event.is_action_pressed("weapon_next"):
		Game.weapon = wrapi(Game.weapon + 1, 1, 3)

	# Respawn when clicking after a certain delay has passed.
	if Game.status == Game.STATUS_DEAD and event.is_action_pressed("attack") and is_zero_approx($RespawnTimer.time_left):
		respawned()

	if event.is_action_pressed("suicide") and Game.status == Game.STATUS_ALIVE:
		rpc("damage", 1000)


# Returns `true` if the player is touching the floor, `false` otherwise.
func is_touching_ground() -> bool:
	return $"Player/RayCast2D".is_colliding()


remotesync func damage(points: int) -> void:
	var remote_animation_player := get_node("/root/Level/Players/%d/Player/AnimationPlayer" % get_tree().get_rpc_sender_id())
	remote_animation_player.play("pain")
	remote_animation_player.playback_speed = 1

	var positional: int = Sound.Type.NON_POSITIONAL if is_network_master() else Sound.Type.POSITIONAL_2D
	if Game.health <= 0:
		Sound.play(positional, self, preload("res://data/sounds/player_death.wav"), 0.5, 1.15)
	else:
		Sound.play(positional, self, preload("res://data/sounds/player_hurt.wav"), 0, rand_range(0.95, 1.05))

	if is_network_master():
		if Game.armor > 0:
			Game.armor = int(max(0, Game.armor - points / 2.0))
			Game.health = int(max(0, Game.health - points / 2.0))
		else:
			Game.health = int(max(0, Game.health - points))


# Called when the player dies.
func die() -> void:
	Game.get_node("HUD").rpc("builtin_notice", Game.get_node("HUD").BuiltinNoticeType.PLAYER_DEATH)

	if is_network_master():
		Game.status = Game.STATUS_DEAD
		$RespawnTimer.wait_time = RESPAWN_DELAY
		$RespawnTimer.start()


# Called when the player respawns.
func respawned() -> void:
	if is_network_master():
		Game.health = 100.0
		Game.armor = 0
		Game.ammo = 25
		Game.weapon = Game.WEAPON_PISTOL
		Game.fuel = 100.0

		Game.time = 0.0
		Game.kills = 0
		Game.items = 0
		Game.status = Game.STATUS_ALIVE

		# Wait for a frame to make position resetting work more reliably.
		player.set_deferred("position", Vector2.ZERO)


func _animation_finished(anim_name: String) -> void:
	match anim_name:
		"pain", "shoot":
			# Go back to the previous walk animation.
			animation_player.play("walk")
