extends Node2D
var brake = false
var accel := 250.0  
var max_speed := 10000.0
var brake_force := 1000.0
@onready var screen_size = get_viewport().get_visible_rect().size
var road_list = []
var roads_made := 0
var meters_until_stop
var pattern_lenght = 200

@onready var meters = $viewport/HBoxContainer/meters
@onready var total = $viewport/HBoxContainer2/total

func generate_pattern(length) -> Array:
	var temp_pattern = []
	var min_zeros_between_ones = 50  # Variable for spacing requirement
	var zeros_since_last_one = min_zeros_between_ones  # Start ready to place a 1
	
	for i in range(length):
		if zeros_since_last_one >= min_zeros_between_ones:
			# Randomly decide to place a 1 (30% chance)
			if randf() > 0.7:
				temp_pattern.append(1)
				zeros_since_last_one = 0 
			else:
				temp_pattern.append(0)
				zeros_since_last_one += 1
		else:
			# Must place a 0
			temp_pattern.append(0)
			zeros_since_last_one += 1
	
	print(temp_pattern)
	return temp_pattern
	

var pattern = generate_pattern(100)

func make_road():
	var road_scene = preload("res://scenes/road.tscn")
	var road = road_scene.instantiate()
	road.position.x = 0
	road.position.y = -230
	road_list.append(road)
	
	if roads_made < pattern.size() and pattern[roads_made] == 1:
		road.get_node("sprite").play("intersection")
	
	elif roads_made >= pattern.size():
		pattern = generate_pattern(pattern_lenght)
		roads_made = 0
	else:
		road.get_node("sprite").play("default")
	
	
	roads_made += 1
	
	add_child(road)



func update_meters():
	var count = 0
	var index = roads_made - 2 # Offset for moved camera
	
	if index >= pattern.size() - 5:  # Generate new pattern 5 roads early
		pattern = generate_pattern(pattern_lenght)
		roads_made = 0
		index = roads_made - 2
		

	while index < pattern.size():
		
		if pattern[index] == 1:
			break
		count += 1
		index += 1
	
	meters.text = str(count)
	total.text = str(int(total.text) + 1)
	
	meters_until_stop = count
	
func _ready() -> void:
	make_road()
	update_meters()


var has_passed = false
var toggle = false
var previous_meters = -1

func _process(delta: float) -> void:
 
	# Check for if you have stopped
	if meters_until_stop != 0 and previous_meters == 0:
		# Just transitioned away from the stop line
		if has_passed:
			print("PASS")
			has_passed = false
			toggle = false
		else:
			print("GAME OVER")
			toggle = true
	elif meters_until_stop == 0 and Globals.main_speed == 0 and not has_passed:
		# Stopped at the line
		has_passed = true
		toggle = true
		print("Stopped")

	previous_meters = meters_until_stop
	
	
	# Spawn new road when the last one reaches the threshold
	if road_list[-1].position.y >= 800:
		make_road()
		update_meters()
	while road_list.size() > 0 and road_list[0].position.y >= 4000:
		
		var old_road = road_list.pop_front()
		old_road.queue_free()
	
	
	
	if brake == true:
		
		if Globals.main_speed >= 0:
			Globals.main_speed -= brake_force * delta
			if Globals.main_speed < 0:
				Globals.main_speed = 0
	else:
		var speed_ratio = Globals.main_speed / max_speed
		var acceleration_factor = 1.0 - (speed_ratio * speed_ratio)  # Exponential falloff
		Globals.main_speed += accel * acceleration_factor * delta
		
		if Globals.main_speed > max_speed:
			Globals.main_speed = max_speed
		
	if Input.is_action_pressed("brake"):
		
		brake = true
		
	else:
		brake = false
