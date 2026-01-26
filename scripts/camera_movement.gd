extends Camera2D

# Look-ahead settings
@export var look_ahead_distance = 100.0
@export var look_ahead_smoothing = 3.0

# Vertical zone settings
@export var upper_zone_threshold = -80.0  # Distance above center to trigger upward movement
@export var lower_zone_threshold = 80.0   # Distance below center to trigger downward movement
@export var vertical_offset_amount = 60.0 # How much to offset camera vertically
@export var vertical_smoothing = 2.5

# Damping/easing
@export var damping = 0.1  # Lower = smoother/slower, higher = more responsive

var target_offset = Vector2.ZERO
var current_offset = Vector2.ZERO

func _process(delta):
	var player = get_parent()
	
	if player.velocity.x != 0:
		var facing_direction = sign(player.velocity.x)
		target_offset.x = facing_direction * look_ahead_distance
	
	var relative_y = player.position.y - global_position.y
	
	if relative_y < upper_zone_threshold:
		target_offset.y = -vertical_offset_amount
		
	elif relative_y > lower_zone_threshold:
		target_offset.y = vertical_offset_amount
		
	else:
		target_offset.y = 0.0
	
	current_offset.x = lerp(current_offset.x, target_offset.x, look_ahead_smoothing * delta)
	current_offset.y = lerp(current_offset.y, target_offset.y, vertical_smoothing * delta)
	
	offset = offset.lerp(current_offset, 1.0 - pow(damping, delta))
