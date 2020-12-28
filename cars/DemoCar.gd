# Player controlled car.
extends "res://cars/car_base.gd"

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
