extends Node2D
var brake = false
var accel := 250.0  
var max_speed := 30000.0  
var brake_force := 1000.0
@onready var screen_size = get_viewport().get_visible_rect().size
var road_list = []

func make_road():
	var road_scene = preload("res://scenes/road.tscn")
	var road = road_scene.instantiate()
	road.position.x = 0
	road.position.y = -230
	road_list.append(road)
	
	add_child(road)
	
func _ready() -> void:
	make_road()
	
func _process(delta: float) -> void:
	
	# Spawn new road when the last one reaches the threshold
	if road_list[-1].position.y >= 800:
		print("Spawn road")
		make_road()
	
	while road_list.size() > 0 and road_list[0].position.y >= 4000:
		print("Despawn road at y =", road_list[0].position.y)
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
