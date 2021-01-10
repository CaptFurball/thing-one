extends KinematicBody

export var player_acceleration : float = 0.5
export var player_sprint_acceleration : float = 1
export var player_deceleration : float = 1
export var player_max_speed : float = 20
export var player_sprint_max_speed : float = 40
export var player_jump_speed : float = 20
export var player_gravity: float = 1
export var player_terminal_speed: float = 60

export(float, 0, 1) var mouse_sensitivity : float = 0.2
export(float, -90, 0) var min_camera_pitch : float = -90
export(float, 0, 90) var max_camera_pitch : float = 90
export(float, 0, 1) var player_turn_speed : float = 0.1

onready var camera_pivot = $CameraPivot
onready var camera = $CameraPivot/Player/CameraPivot/CameraBoom/Camera

var player_velocity : Vector3
var player_velocity_y : float = 0
var player_direction : Vector3 = Vector3()
var player_speed : float = 0

func _ready():
	capture_mouse()

func _input(event):
	if event is InputEventMouseButton:
		capture_mouse()
	
	if event is InputEventMouseMotion:
		handle_camera_rotation(event)

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(_delta):
	if is_on_floor():
		if Input.is_action_pressed("move_forward"):	
			reset_camera()	
			if Input.is_action_pressed("sprint"):
				player_speed += player_sprint_acceleration
			else:
				player_speed += player_acceleration
			player_direction = Vector3()
			player_direction -= transform.basis.z

		if Input.is_action_pressed("move_backward"):
			reset_camera()	
			player_speed += player_acceleration
			player_direction = Vector3()
			player_direction += transform.basis.z

		if Input.is_action_pressed("strafe_left"):
			reset_camera()	
			player_speed += player_acceleration
			player_direction = Vector3()
			player_direction -= transform.basis.x
			
		if Input.is_action_pressed("strafe_right"):
			reset_camera()
			player_speed += player_acceleration
			player_direction = Vector3()
			player_direction += transform.basis.x

		if !Input.is_action_pressed("move_forward") && !Input.is_action_pressed("move_backward") && !Input.is_action_pressed("strafe_left") &&!Input.is_action_pressed("strafe_right"):
			if is_on_floor():
				player_speed -= player_deceleration

		if Input.is_action_just_pressed("jump"):
			player_velocity_y = player_jump_speed
		else:
			player_velocity_y = -0.01
	else:
		player_velocity_y -= player_gravity

	player_velocity_y = clamp(player_velocity_y, -player_terminal_speed, player_terminal_speed)

	player_direction = player_direction.normalized()

	if Input.is_action_pressed("move_forward") && Input.is_action_pressed("sprint"):
		player_speed = clamp(player_speed, 0, player_sprint_max_speed)
	else:
		player_speed = clamp(player_speed, 0, player_max_speed)

	player_velocity = player_direction * player_speed

	player_velocity.y = player_velocity_y

	player_velocity = move_and_slide(player_velocity, Vector3.UP)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func handle_camera_rotation(event):
	# handle camera yaw - method 1
	camera_pivot.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		
	# handle camera pitch
	camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity
	camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, min_camera_pitch, max_camera_pitch)

func reset_camera():
	if camera_pivot.rotation_degrees.y != 0:
		var camera_rotation_degrees_y : float = camera_pivot.rotation_degrees.y
		var abs_camera_rotation_degrees_y : float = abs(camera_rotation_degrees_y)
		var camera_rotation_direction : float = camera_rotation_degrees_y / abs_camera_rotation_degrees_y

		# convert overlapped rotations (eg: 810) to single rotation (eg: 90)
		if abs_camera_rotation_degrees_y > 360:
			# find remainder rotation
			var remainder_rotation : float = fmod(abs_camera_rotation_degrees_y, 360)

			# remove overlapped rotation
			camera_rotation_degrees_y = camera_rotation_direction * remainder_rotation

		# find a shorter path to rotate (eg: instead of 270, use -90)
		if 360 - abs(camera_rotation_degrees_y) < 180:
			camera_rotation_degrees_y = -1 * camera_rotation_direction * (360 - abs(camera_rotation_degrees_y))

		rotation_degrees.y += player_turn_speed * camera_rotation_degrees_y

		camera_pivot.rotation_degrees.y = (1 - player_turn_speed) * camera_rotation_degrees_y

