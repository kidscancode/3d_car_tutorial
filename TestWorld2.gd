extends Spatial

func get_path_direction(position):
	var offset = $Path.curve.get_closest_offset(position)
	$Path/PathFollow.offset = offset
	return $Path/PathFollow.transform.basis.z
