extends Node2D

var brake := false
var random



func _ready() -> void:
	if $AnimatedSprite2D.animation == "default":
		$Area2d/line.disabled = true
	else:
		$Area2d/line.disabled = false
	pass

func _process(delta: float) -> void:
	
	position.y += Globals.main_speed * delta

	if Input.is_action_pressed("brake"):
		brake = true
	else:
		brake = false
