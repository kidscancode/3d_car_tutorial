extends "res://cars/car_base.gd"

export var num_rays = 16
export var look_ahead = 3.0
export var brake_distance = 5.0

var interest = []
var danger = []
var chosen_dir = Vector3.ZERO
var forward_ray

var tail_lights = preload("res://assets/cars/lightBack.material")

func _ready():
	randomize()
	engine_power *= rand_range(0.9, 1.1)
	interest.resize(num_rays)
	danger.resize(num_rays)
	add_rays()
	DebugOverlay.stats.add_property(self, "velocity", "length")


func add_rays():
	var angle = 2 * PI / num_rays
	for i in num_rays:
		var r = RayCast.new()
		$ContextRays.add_child(r)
		r.cast_to = Vector3.FORWARD * look_ahead
		r.rotation.y = -angle * i
		r.add_exception(self)
		r.enabled = true
	forward_ray = $ContextRays.get_child(0)


func get_input():
	set_interest()
	set_danger()
	choose_direction()
	
	var a = angle_dir(-transform.basis.z, chosen_dir, transform.basis.y)
	steer_angle = a * deg2rad(steering_limit)
	$tmpParent/sedanSports/wheel_frontRight.rotation.y = steer_angle
	$tmpParent/sedanSports/wheel_frontLeft.rotation.y = steer_angle
	acceleration = -transform.basis.z * engine_power
	# Hit brakes if obstacle dead ahead
	tail_lights.emission_enabled = false
	if forward_ray.is_colliding():
		var d = transform.origin.distance_to(forward_ray.get_collider().transform.origin)
		if d < brake_distance:
			acceleration += -transform.basis.z * braking# * (1 - d/brake_distance)
			tail_lights.emission_enabled = true

func angle_dir(fwd, target, up):
	# Returns how far "target" vector is to the left (negative)
	# or right (positive) of "fwd" vector.
	var p = fwd.cross(target)
	var dir = p.dot(up)
	return dir


func set_interest():
	# Go forward unless the world has a path.
	var path_direction = -transform.basis.z
	if owner and owner.has_method("get_path_direction"):
		path_direction = owner.get_path_direction(transform.origin)
		
	for i in num_rays:
		var d = -$ContextRays.get_child(i).global_transform.basis.z
		d = d.dot(path_direction)
		interest[i] = max(0, d)


func set_danger():
	for i in num_rays:
		var ray = $ContextRays.get_child(i)
		danger[i] = 1.0 if ray.is_colliding() else 0.0


func choose_direction():
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	chosen_dir = Vector3.ZERO
	for i in num_rays:
		chosen_dir += -$ContextRays.get_child(i).global_transform.basis.z * interest[i]
	chosen_dir = chosen_dir.normalized()
