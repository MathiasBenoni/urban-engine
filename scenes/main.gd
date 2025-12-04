extends Node2D


@onready var map := $Sprite2D

@export var stepper := 50.0


var brake = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	
	if brake == true:
		map.position.y += stepper * delta * 0.2
	else:
		map.position.y += stepper * delta
	if Input.is_action_pressed("brake"):
		brake = true
		print("BRAKE")
	else:
		brake = false
