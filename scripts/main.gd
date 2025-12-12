extends Node2D


var brake = false

@onready var screen_size = get_viewport().get_visible_rect().size

var road_list = []


func make_road():
	var road_scene = preload("res://scenes/road.tscn")
	var road = road_scene.instantiate()
	road.position.x = 0
	road.position.y = -235
	road_list.append(road)
	
	add_child(road)
	
func _ready() -> void:
	make_road()
	


func _process(delta: float) -> void:
	
	if road_list[-1].position.y >= screen_size.y + 235:
		print("Spawn road")
		make_road()
		road_list.pop_front()
	
	
	#print(Globals.main_speed)
	
	if brake == true:
		if Globals.main_speed >= 0:
			Globals.main_speed -= 10 * delta
		
	else:
		Globals.main_speed += 10 * delta
		

	if Input.is_action_pressed("brake"):
		brake = true
	else:
		brake = false
