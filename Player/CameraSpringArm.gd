extends SpringArm3D

@export var mouse_sensitivity := 0.01
@export_range(-90.00, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle := -PI/2
@export_range(0.00, 90.0, 0.1, "radians_as_degrees") var max_vertical_angle := PI/4


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity	
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, min_vertical_angle, max_vertical_angle)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
