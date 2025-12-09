extends Node2D

var main_speed := 10.0

var brake = false

@onready var screen_size = get_viewport().get_visible_rect().size

func make_road():
	var road_scene = preload("res://scenes/road.tscn")
	var road = road_scene.instantiate()
	add_child(road)

func _ready() -> void:
	make_road()
	
	

func _process(delta: float) -> void:
	
	if $road.position.y >= screen_size.y:
		print("HALLO")
	
	
	
	#print(main_speed)
	
	
	
	
	if brake == true:	
		if main_speed >= 0:
			main_speed -= 10 * delta
		$road.position.y += main_speed * delta
	else:
		$road.position.y += main_speed * delta
		main_speed += 10 * delta
		

	if Input.is_action_pressed("brake"):
		brake = true
	else:
		brake = false
