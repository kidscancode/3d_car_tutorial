# Player controlled car.
extends "res://cars/car_base.gd"

signal change_camera

var current_camera = 0
onready var num_cameras = $CameraPositions.get_child_count()
var tail_lights = preload("res://assets/cars/lightBack.material")


func _ready():
	emit_signal("change_camera", $CameraPositions.get_child(current_camera))
	DebugOverlay.draw.add_vector(self, "velocity", 1, 4, Color(0, 1, 0, 0.5))
	DebugOverlay.stats.add_property(self, "velocity", "length")
	DebugOverlay.stats.add_property(self, "steer_angle", "round")
	DebugOverlay.stats.add_property(self, "drifting", "")

func _input(event):
	if event.is_action_pressed("change_camera"):
		current_camera = wrapi(current_camera + 1, 0, num_cameras)
		emit_signal("change_camera", $CameraPositions.get_child(current_camera))


func get_input():
	var turn = Input.get_action_strength("steer_left")
	turn -= Input.get_action_strength("steer_right")
	steer_angle = turn * deg2rad(steering_limit)
	# Rotate the wheel meshes - exaggerate for effect.
	$tmpParent/sedanSports/wheel_frontRight.rotation.y = steer_angle*2
	$tmpParent/sedanSports/wheel_frontLeft.rotation.y = steer_angle*2

	acceleration = Vector3.ZERO
	if Input.is_action_pressed("accelerate"):
		acceleration = -transform.basis.z * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = -transform.basis.z * braking
		tail_lights.emission_enabled = true
	else:
		tail_lights.emission_enabled = false
