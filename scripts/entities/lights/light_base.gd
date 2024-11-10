## Special Light base class that contains static helper functions for LightOmni and LightSpot entities.
class_name LightBase
extends Light3D

static func _func_godot_apply_properties(node: Light3D, props: Dictionary) -> void:
	node.light_energy = props["energy"] as float
	node.light_indirect_energy = props["indirect_energy"] as float
	node.shadow_bias = props["shadow_bias"] as float
	node.shadow_enabled = props["shadows"] as bool
	node.light_color = props["color"] as Color
	node.light_bake_mode = Light3D.BAKE_DYNAMIC
