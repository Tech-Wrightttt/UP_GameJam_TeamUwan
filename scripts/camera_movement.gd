extends Camera2D

# Horizontal look-ahead
@export_group("Horizontal Movement")
@export var look_ahead_distance = 120.0
@export var look_ahead_speed = 4.0
@export var look_ahead_delay = 0.15  # Delay before camera starts following direction change
@export var look_ahead_transition_speed = 1.0  # How fast the look-ahead offset transitions (lower = slower)

# Focus zones (Silksong-style)
@export_group("Focus Zones")
@export var focus_zone_width = 40.0  # Horizontal deadzone
@export var focus_zone_height = 60.0  # Vertical deadzone
@export var edge_snap_speed = 6.0

# Vertical offset based on look direction
@export_group("Vertical Look")
@export var look_up_offset = -100.0
@export var look_down_offset = 100.0
@export var look_input_threshold = 0.3  # How long to hold before camera moves
@export var vertical_transition_speed = 2.5

# Smoothing and feel
@export_group("Camera Feel")
@export var base_smoothing = 8.0
@export var air_smoothing_multiplier = 0.7  # Slightly faster in air
@export var direction_change_smoothing = 3.0  # Slower when changing direction

# Internal state
var target_position = Vector2.ZERO
var last_facing_direction = 1
var direction_change_timer = 0.0
var look_input_timer = 0.0
var current_vertical_look = 0.0
var current_horizontal_offset = 0.0
var target_horizontal_offset = 0.0

func _ready():
	var player = get_parent()
	target_position = player.global_position

func _process(delta):
	var player = get_parent()
	var base_target = player.global_position
	
	target_horizontal_offset = 0.0
	
	if abs(player.velocity.x) > 10.0:
		var facing_direction = sign(player.velocity.x)
		
		if facing_direction != last_facing_direction:
			direction_change_timer = look_ahead_delay
			last_facing_direction = facing_direction
		
		if direction_change_timer > 0.0:
			direction_change_timer -= delta
		else:
			target_horizontal_offset = facing_direction * look_ahead_distance
	
	current_horizontal_offset = lerp(current_horizontal_offset, target_horizontal_offset, look_ahead_transition_speed * delta)
	
	var vertical_input = 0.0
	
	if Input.is_action_pressed("ui_up"):
		vertical_input = -1.0
	elif Input.is_action_pressed("ui_down"):
		vertical_input = 1.0
	
	if abs(vertical_input) > 0.5:
		look_input_timer += delta
	else:
		look_input_timer = 0.0
	
	var target_vertical_look = 0.0
	if look_input_timer > look_input_threshold:
		if vertical_input < 0:
			target_vertical_look = look_up_offset
		elif vertical_input > 0:
			target_vertical_look = look_down_offset
	
	current_vertical_look = lerp(current_vertical_look, target_vertical_look, vertical_transition_speed * delta)
	
	var focus_offset = Vector2.ZERO
	var player_screen_pos = player.global_position - global_position
	
	if abs(player_screen_pos.x) > focus_zone_width:
		focus_offset.x = sign(player_screen_pos.x) * (abs(player_screen_pos.x) - focus_zone_width)
	
	if abs(player_screen_pos.y) > focus_zone_height:
		focus_offset.y = sign(player_screen_pos.y) * (abs(player_screen_pos.y) - focus_zone_height)
	
	var desired_position = base_target + Vector2(current_horizontal_offset, current_vertical_look) + focus_offset
	
	# Handle camera limits to prevent look-ahead from pushing player off-screen
	var viewport_size = get_viewport_rect().size
	var half_viewport_width = viewport_size.x / (2.0 * zoom.x)
	var half_viewport_height = viewport_size.y / (2.0 * zoom.y)
	
	var clamped_position = desired_position
	
	var has_left_limit = limit_left > -10000000
	var has_right_limit = limit_right < 10000000
	var has_top_limit = limit_top > -10000000
	var has_bottom_limit = limit_bottom < 10000000
	
	if has_left_limit:
		clamped_position.x = max(clamped_position.x, limit_left + half_viewport_width)
	if has_right_limit:
		clamped_position.x = min(clamped_position.x, limit_right - half_viewport_width)
	if has_top_limit:
		clamped_position.y = max(clamped_position.y, limit_top + half_viewport_height)
	if has_bottom_limit:
		clamped_position.y = min(clamped_position.y, limit_bottom - half_viewport_height)
	
	var final_horizontal_offset = current_horizontal_offset
	var final_vertical_offset = current_vertical_look
	
	if has_left_limit and abs(clamped_position.x - (limit_left + half_viewport_width)) < 1.0:
		if current_horizontal_offset < 0:
			final_horizontal_offset = 0
	
	if has_right_limit and abs(clamped_position.x - (limit_right - half_viewport_width)) < 1.0:
		if current_horizontal_offset > 0:
			final_horizontal_offset = 0
	
	if has_top_limit and abs(clamped_position.y - (limit_top + half_viewport_height)) < 1.0:
		if final_vertical_offset < 0:
			final_vertical_offset = 0
	
	if has_bottom_limit and abs(clamped_position.y - (limit_bottom - half_viewport_height)) < 1.0:
		if final_vertical_offset > 0:
			final_vertical_offset = 0
	
	target_position = base_target + Vector2(final_horizontal_offset, final_vertical_offset) + focus_offset
	
	var smoothing = base_smoothing
	
	if not player.is_on_floor():
		smoothing *= air_smoothing_multiplier
	
	if direction_change_timer > 0.0:
		smoothing = direction_change_smoothing
	
	global_position = global_position.lerp(target_position, smoothing * delta)
	
	reset_smoothing()
