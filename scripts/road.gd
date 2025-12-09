extends Node2D

var brake := false

var speed := 10.0

func _process(delta: float) -> void:
	
	if brake == true:
		if speed >= 0:
			speed -= 10 * delta
			
		position.y += speed * delta
	else:
		position.y += speed * delta
		speed += 10 * delta


	if Input.is_action_pressed("brake"):
		brake = true
	else:
		brake = false
