extends Node2D

var brake := false
var random

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position.y += Globals.main_speed * delta
	
	if $sprite.animation == "intersection":
		$trafficlights.visible = true
		
	else:
		$trafficlights.visible = false

	if Input.is_action_pressed("brake"):
		brake = true
	else:
		brake = false
