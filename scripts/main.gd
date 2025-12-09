extends Node2D

var main_speed := 10.0

@onready var map := $Sprite2D
@export var stepper := 50.0

var brake = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	print(main_speed)
	
	if brake == true:
		map.position.y += stepper * delta * 0.2 * main_speed
		
		if main_speed >= 1:
			main_speed -= 10 * delta
	else:
		
		main_speed += 10 * delta
		
		
		map.position.y += stepper * main_speed * delta
	if Input.is_action_pressed("brake"):
		brake = true
	else:
		brake = false
