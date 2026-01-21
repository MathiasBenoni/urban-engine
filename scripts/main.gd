extends Node2D

# Movement
var brake = false
var accel := 500.0  
var max_speed := 10000.0
var brake_force := 1000.0

# Road scrolling
var scroll_offset := 0.0
var tile_height := 230.0

# Intersection management
var intersections = []  # Array of intersection nodes
var next_intersection_spawn := 0.0  # Y position to spawn next intersection
var min_gap := 25  # Minimum tiles between intersections

# Game state
var goal := 0
var distance_traveled := 0
var safe := false
var has_passed := false
var was_at_intersection := false
var current_intersection = null  # Track which intersection we stopped for

@onready var meters = $viewport/HBoxContainer/meters
@onready var total = $viewport/HBoxContainer2/total
@onready var player = $player  # Reference to your player node
@onready var road_sprite = $Sprite2D  # Sprite2D for the road

func _ready() -> void:
	goal = randi_range(100, 200)
	
	# Setup the road sprite for region scrolling
	if road_sprite and road_sprite.texture:
		road_sprite.region_enabled = true
		var texture_height = road_sprite.texture.get_height()
		var texture_width = road_sprite.texture.get_width()
		# Make region tall enough to cover the screen with repeating texture
		road_sprite.region_rect = Rect2(0, 0, texture_width, texture_height * 10)
	
	# Pre-spawn intersections
	next_intersection_spawn = -tile_height * randf_range(3, 8)  # First one a few tiles up
	for i in range(5):  # Spawn 5 intersections in advance
		spawn_intersection()
	
	update_ui()

func spawn_intersection():
	var intersection_scene = preload("res://scenes/intersection.tscn")
	var intersection = intersection_scene.instantiate()
	
	intersection.position.x = 0
	intersection.position.y = next_intersection_spawn
	
	intersections.append(intersection)
	$intersections.add_child(intersection)
	
	# Schedule next intersection spawn position
	next_intersection_spawn -= tile_height * randf_range(min_gap, min_gap * 1.5)

func _process(delta: float) -> void:
	# Handle braking/acceleration
	if Input.is_action_pressed("brake") or brake:
		if Globals.main_speed >= 0:
			Globals.main_speed -= brake_force * delta
			if Globals.main_speed < 0:
				Globals.main_speed = 0
	else:
		var speed_ratio = Globals.main_speed / max_speed
		var acceleration_factor = 1.0 - (speed_ratio * speed_ratio)
		Globals.main_speed += accel * acceleration_factor * delta
		if Globals.main_speed > max_speed:
			Globals.main_speed = max_speed
	
	var movement = Globals.main_speed * delta
	
	# Scroll the road sprite by changing region offset (at half speed)
	scroll_offset += movement * 0.3
	if road_sprite and road_sprite.texture:
		var texture_height = road_sprite.texture.get_height()
		var region = road_sprite.region_rect
		# Scroll in the opposite direction (subtract instead of add)
		region.position.y = fmod(-scroll_offset, texture_height)
		if region.position.y < 0:
			region.position.y += texture_height
		road_sprite.region_rect = region
	
	# Move intersections
	for intersection in intersections:
		intersection.position.y += movement
	
	# Check intersection logic
	check_intersection_collision()
	
	# Cleanup old intersections and spawn new ones
	var i = 0
	while i < intersections.size():
		if intersections[i].position.y > 4000:
			intersections[i].queue_free()
			intersections.remove_at(i)
		else:
			i += 1
	
	# Spawn more intersections if needed
	while intersections.size() < 5:
		spawn_intersection()
	
	# Update UI
	distance_traveled += movement / tile_height
	update_ui()
	
	brake = Input.is_action_pressed("brake")

	if distance_traveled >= goal:
		print("DONE")

func get_distance_to_next_intersection() -> float:
	var closest_distance = -99999.0  # Start with very negative number
	
	for intersection in intersections:
		var dist = intersection.global_position.y - player.global_position.y
		# Look for intersections ABOVE the player (negative distance, but closest to 0)
		if dist < 0 and dist > closest_distance:
			closest_distance = dist
	
	if closest_distance == -99999.0:
		return 0.0  # Return 0 if no intersection found
	
	return abs(closest_distance) / tile_height  # Return positive distance for display

func get_next_intersection():
	var closest_intersection = null
	var closest_distance = -99999.0
	
	for intersection in intersections:
		var dist = intersection.global_position.y - player.global_position.y
		# Look for intersections ABOVE the player (negative distance, closest to 0)
		if dist < 0 and dist > closest_distance:
			closest_distance = dist
			closest_intersection = intersection
	
	return closest_intersection

func check_intersection_collision():
	var next_inter = get_next_intersection()
	
	if next_inter == null:
		return
	
	# If this is a new intersection, reset has_passed
	if current_intersection != next_inter:
		has_passed = false
		safe = false  # Reset safe flag for new intersection
		current_intersection = next_inter
	
	var distance = next_inter.global_position.y - player.global_position.y
	# distance is NEGATIVE because intersection is ABOVE player
	
	# Stopping zone: 0.5-3 tiles before (above) the intersection
	var in_stopping_zone = distance < -tile_height * 0.5 and distance > -tile_height * 3.0
	# Danger zone: at or past the intersection (within 0.5 tiles above)
	var in_danger_zone = distance >= -tile_height * 0.5
	
	# Check if player stops in the stopping zone (and remember it)
	if in_stopping_zone and Globals.main_speed < 10 and not has_passed:
		has_passed = true
		print("Stopped correctly at distance: " + str(abs(distance) / tile_height) + " tiles")
		$trafficlight.start()
	
	# If we enter the danger zone
	if in_danger_zone:
		if not has_passed:
			# Never stopped - FAIL
			print("Ran intersection! Distance: " + str(abs(distance) / tile_height) + " tiles")
			game_over()
			return
		elif has_passed and not safe:
			# Stopped but light hasn't turned green yet - FAIL
			print("Left before green light!")
			game_over()
			return
	
	# If we've passed the intersection completely (1 tile behind/below)
	if distance > tile_height * 1.0 and has_passed and safe:
		print("PASS - Made it through!")
		has_passed = false
		safe = false
		current_intersection = null  # Clear current intersection

func update_ui():
	var dist = get_distance_to_next_intersection()
	meters.text = str(max(0, int(dist)))
	total.text = str(max(0, int(goal - distance_traveled)))

func game_over():
	print("GAME OVER")
	get_tree().paused = true

func _on_trafficlight_timeout() -> void:
	print("NOW")
	safe = true
	get_tree().call_group("traffic_lights", "play", "green")
