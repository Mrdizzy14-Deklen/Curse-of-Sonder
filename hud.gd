extends Control


signal attack_button_pressed


@onready var joystick: VirtualJoystick = $"Virtual Joystick"
@onready var attack_button: Control = $AttackButton
@onready var attack_button_2: Button = $AttackButton/AttackButton2


func _ready() -> void:
	
	# Hides/Shows button
	if !(OS.has_feature("web_android") or OS.has_feature("web_ios")):
		attack_button.hide()
		attack_button_2.disabled = true
		
	pass


func _input(event: InputEvent) -> void:
	
	# Sends attack signal
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_button_area(event.position):
				attack_button_pressed.emit()
	
	pass

func _is_point_inside_button_area(point: Vector2):
	var x: bool = point.x >= attack_button.global_position.x and point.x <= attack_button.global_position.x + (attack_button.size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= attack_button.global_position.y and point.y <= attack_button.global_position.y + (attack_button.size.y * get_global_transform_with_canvas().get_scale().y)
	print_debug(x, " ", y)
	return x and y
