@tool
class_name LightSpot
extends SpotLight3D

func _func_godot_apply_properties(props: Dictionary) -> void:
	LightBase._func_godot_apply_properties(self, props)
	spot_angle = props["angle"] as float
	spot_range = (props["range"] as float) * GameManager.INVERSE_SCALE
