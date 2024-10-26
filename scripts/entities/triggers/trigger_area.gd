@tool
class_name TriggerArea
extends Area3D

@export var target: String = ""
@export var targetfunc: String = ""
@export var targetname: String = ""

enum TriggerStates {
	READY,
	USED
}
var trigger_state: TriggerStates = TriggerStates.READY
var timeout: float = 0.0
var last_activator: Node = null

func _func_godot_apply_properties(props: Dictionary) -> void:
	target = props["target"] as String
	targetfunc = props["targetfunc"] as String
	targetname = props["targetname"] as String

func toggle_collision(toggle: bool) -> void:
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", !toggle)

func use() -> void:
	if trigger_state == TriggerStates.READY:
		trigger_state = TriggerStates.USED
		toggle_collision(false)
		GM.use_targets(self, target)

func _on_ent_entered(ent: Node) -> void:
	if trigger_state == TriggerStates.READY:
		if ent.is_in_group("PLAYER"):
			call("use")

func _init() -> void:
	monitoring = true
	monitorable = false
	connect("body_entered", _on_ent_entered)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	GM.set_targetname(self, targetname)
