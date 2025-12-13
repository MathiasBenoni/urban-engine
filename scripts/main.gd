extends Node2D
var brake = false
var accel := 250.0  
var max_speed := 10000.0
var brake_force := 1000.0
@onready var screen_size = get_viewport().get_visible_rect().size
var road_list = []
var roads_made := 0


func generate_pattern(length) -> Array:
	var pattern = []
	var zeros_since_last_one = 20  # Start at 20 so first element can be a 1
	
	for i in range(length):
		# Can only place a 1 if we've had at least 20 zeros since the last 1
		if zeros_since_last_one >= 20:
			# Randomly decide to place a 1 (30% chance)
			if randf() > 0.7:
				pattern.append(1)
				zeros_since_last_one = 0  # Reset counter
			else:
				pattern.append(0)
				zeros_since_last_one += 1
		else:
			# Must place a 0
			pattern.append(0)
			zeros_since_last_one += 1
	print(pattern)
	return pattern

var pattern = generate_pattern(100)

func make_road():
	var road_scene = preload("res://scenes/road.tscn")
	var road = road_scene.instantiate()
	road.position.x = 0
	road.position.y = -230
	road_list.append(road)
	
	if roads_made < pattern.size() and pattern[roads_made] == 1:
		road.get_node("sprite").play("intersection")
	else:
		road.get_node("sprite").play("default")
	
	
	roads_made += 1
	
	add_child(road)



func _ready() -> void:
	
	
	
	make_road()
	
func _process(delta: float) -> void:
	
	# Spawn new road when the last one reaches the threshold
	if road_list[-1].position.y >= 800:
		
		make_road()
	
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
		print(Globals.main_speed)
	else:
		brake = false
