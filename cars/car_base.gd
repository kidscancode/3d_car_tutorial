extends KinematicBody

# Car behavior parameters, adjust as needed.
export var gravity = -20.0
export var wheel_base = 0.6  # Distance between front/rear axles
export var steering_limit = 10.0  # Front wheel max turning angle (deg)
export var engine_power = 6.0
export var braking = -9.0
export var friction = -5.0
export var drag = -2.0
export var max_speed_reverse = 3.0
export var slip_speed = 9.0  # Speed where traction is lost.
export var traction_slow = 0.75  # Traction when below slip_speed.
export var traction_fast = 0.02  # Traction when drifting.

# Car state properties.
var acceleration = Vector3.ZERO
var velocity = Vector3.ZERO
var steer_angle = 0.0  # Current wheel angle.
var drifting = false

onready var front_ray = $FrontRay
onready var rear_ray = $RearRay

func _physics_process(delta):
	# If the car's in the air, you can't steer or accelerate.
	if is_on_floor():
		get_input()
		apply_friction(delta)
		calculate_steering(delta)
	acceleration.y = gravity
	velocity += acceleration * delta
	velocity = move_and_slide_with_snap(velocity,
				-transform.basis.y, Vector3.UP, true)
	# Align with slopes
	# If either wheel is in the air, align to slope
	if front_ray.is_colliding() or rear_ray.is_colliding():
		# If one wheel is in air, move it down
		var nf = front_ray.get_collision_normal() if front_ray.is_colliding() else Vector3.UP
		var nr = rear_ray.get_collision_normal() if rear_ray.is_colliding() else Vector3.UP
		var n = ((nr + nf) / 2.0).normalized()
		var xform = align_with_y(global_transform, n)
		global_transform = global_transform.interpolate_with(xform, 0.1)


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func apply_friction(delta):
	# Stop coasting if velocity is very low.
	if velocity.length() < 0.5 and acceleration.length() == 0:
		velocity.x = 0
		velocity.z = 0
	# Friction is proportional to velocity.
	var friction_force = velocity * friction * delta
	# Drag is proportional to velocity squared.
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func calculate_steering(delta):
	# Using bicycle model (one front/rear wheel)
	var rear_wheel = transform.origin + transform.basis.z * wheel_base / 2.0
	var front_wheel = transform.origin - transform.basis.z * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(transform.basis.y, steer_angle) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)

	# traction
	if not drifting and velocity.length() > slip_speed:
		drifting = true
	if drifting and velocity.length() < slip_speed and steer_angle == 0:
		drifting = false
	var traction = traction_fast if drifting else traction_slow

	# Are we going forward or reverse?
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
#		velocity = new_heading * velocity.length()
		velocity = lerp(velocity, new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	
	# Point in the steering direction.
	# Note: not necessarily the velocity direction.
	look_at(transform.origin + new_heading, Vector3.UP)

func get_input():
	# Override this in inherited scripts for controls
	pass
