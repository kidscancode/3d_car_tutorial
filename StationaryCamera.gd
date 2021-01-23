extends Camera

export var lerp_speed = 10.0
export (NodePath) var target_path

var target = null


func _ready():
	if target_path:
		target = get_node(target_path)

func _process(_delta):
	if !target:
		return
	look_at(target.global_transform.origin, Vector3.UP)

