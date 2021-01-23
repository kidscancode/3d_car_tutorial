extends Camera

export var lerp_speed = 3.0

export (NodePath) var target_path = null
var target = null
var target_pos = null
var target_num = 0

func _ready():
	if target_path:
		target = get_node(target_path)
		target_pos = target.get_node("CameraPositions").get_child(target_num)

func _physics_process(delta):
	if !target:
		return
	global_transform = global_transform.interpolate_with(target_pos.global_transform, lerp_speed * delta)

func _input(event):
	if event.is_action_pressed("change_camera"):
		target_num = wrapi(target_num + 1, 0, target.get_node("CameraPositions").get_child_count())
		target_pos = target.get_node("CameraPositions").get_child(target_num)
		
#func _on_change_camera(t):
#	target = t
