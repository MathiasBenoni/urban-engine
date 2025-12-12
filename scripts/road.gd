extends Node2D

var brake := false


func _process(delta: float) -> void:
	position.y += Globals.main_speed * delta


	if Input.is_action_pressed("brake"):
		brake = true
	else:
		brake = false
