@tool
class_name InfoCamera
extends Camera3D

@export var targetname: String = ""
@export var camera_target: Node3D = null

func _func_godot_apply_properties(props: Dictionary) -> void:
	targetname = props["targetname"] as String
	current = props["active"] as bool
	var targ_node: Node = get_parent().get_node_or_null("entity_" + (props["camera_target"] as String))
	if targ_node != null:
		if 'position' in targ_node:
			camera_target = targ_node
			look_at(camera_target.global_position)

func use() -> void:
	current = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	GM.set_targetname(self, targetname)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if camera_target:
		look_at(camera_target.global_position)
