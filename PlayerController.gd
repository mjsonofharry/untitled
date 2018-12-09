extends KinematicBody


const SPEED = 6
const WALK_SPEED = 2
const ACCELERATION = 10
const DEACCELERATION = 10
const GRAVITY = -9.8
const JUMP_SPEED = 3
const MAX_SLOPE_ANGLE = 40
const LOOK_SENSITIVITY = 0.1


var m_yaw = 0
var m_pitch = 0
var m_velocity = Vector3()


func _ready():
	set_process_input(true)


func _process(delta):
	var camera_basis = get_node("yaw/camera").get_global_transform().basis
	var direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= camera_basis[2]
	if Input.is_action_pressed("move_backward"):
		direction += camera_basis[2]
	if Input.is_action_pressed("move_left"):
		direction -= camera_basis[0]
	if Input.is_action_pressed("move_right"):
		direction += camera_basis[0]
	direction.y = 0
	direction = direction.normalized()
	
	var target = direction * (WALK_SPEED if Input.is_action_pressed("walk") else SPEED)
	var floor_velocity = Vector3(m_velocity.x, 0, m_velocity.z)
	var acceleration = ACCELERATION if direction.dot(floor_velocity) > 0 else DEACCELERATION
	floor_velocity = floor_velocity.linear_interpolate(target, acceleration * delta)

	m_velocity.x = floor_velocity.x
	m_velocity.z = floor_velocity.z
	m_velocity.y += delta * GRAVITY
	m_velocity = move_and_slide(m_velocity, Vector3(0, 1, 0))
	if (is_on_floor() and Input.is_action_pressed("jump")):
		m_velocity.y = JUMP_SPEED


func _input(ie):
	var x = 0
	var y = 0

	if ie is InputEventMouseMotion:
		m_yaw = fmod(m_yaw - ie.relative[0] * LOOK_SENSITIVITY, 360)
		m_pitch = max(min(m_pitch - ie.relative[1] * LOOK_SENSITIVITY, 90), -90)
		get_node("yaw").set_rotation(Vector3(0, deg2rad(m_yaw), 0))
		get_node("yaw/camera").set_rotation(Vector3(deg2rad(m_pitch), 0, 0))


func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
