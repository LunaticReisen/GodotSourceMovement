@tool
class_name LightOmni
extends OmniLight3D

func _func_godot_apply_properties(props: Dictionary) -> void:
	LightBase._func_godot_apply_properties(self, props)
	omni_range = (props["range"] as float) * GameManager.INVERSE_SCALE
