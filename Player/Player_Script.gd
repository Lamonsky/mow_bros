extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.5

@export_group("Movement")
@export var speed: float = 8.0
@export var acceleration: float = 20.0
@export var gravity: float = -30.0
@export var jump_speed: float = 12.0
@export var rotation_speed: float = 12.0

@export_group("Health")
@export var max_health: int = 100
@export var health: int = max_health

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %player


var _camera_input_direction : Vector2 = Vector2.ZERO
var _last_movement_direction: Vector3 = Vector3.BACK

func _ready():
	# Initialize player state
	health = max_health
	print("Player ready with health: ", health)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)  # Limit vertical rotation -30 to 60 degrees
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO  # Reset input direction after processing

	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x

	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0  # Ensure movement is horizontal
	move_direction = move_direction.normalized()

	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * speed, acceleration * delta)
	velocity.y = y_velocity + gravity * delta  # Apply gravity

	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()

	if is_starting_jump:
		velocity.y += jump_speed  # Apply jump speed
	

	move_and_slide()

	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)



func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity
