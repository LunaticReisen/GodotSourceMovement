@tool
class_name FuncMove
extends AnimatableBody3D

@export var targetname: String = ""
@export var move_pos: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
@export var move_rot: Vector3 = Vector3.ZERO
@export var speed: float = 3.0

enum MoveStates {
	READY,
	MOVE
}
var move_state: MoveStates = MoveStates.READY
var move_progress: float = 0.0
var move_progress_target: float = 0.0
var sfx: AudioStreamPlayer3D

func _func_godot_apply_properties(props: Dictionary) -> void:
	targetname = props["targetname"] as String
	move_pos[1] = GameManager.id_vec_to_godot_vec(props["move_pos"]) * GameManager.INVERSE_SCALE
	if props["move_rot"] is Vector3:
		var r: Vector3 = props["move_rot"]
		for i in 3:
			move_rot[i] = deg_to_rad(r[i])
	speed = props["speed"] as float

func mv_forward() -> void:
	move_progress_target = 1.0

func mv_reverse() -> void:
	move_progress_target = 0.0

func use() -> void:
	mv_forward()

func toggle() -> void:
	if move_progress_target > 0.0:
		mv_reverse()
	else:
		mv_forward()

func _init() -> void:
	add_to_group("func_move")
	sync_to_physics = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	GAME.set_targetname(self, targetname)
	move_pos[0] = position
	move_pos[1] += move_pos[0]
	if speed > 0.0:
		speed = 1.0 / speed

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if move_progress != move_progress_target:
		if move_progress < move_progress_target:
			move_progress = minf(move_progress + speed * delta, move_progress_target)
		elif move_progress > move_progress_target:
			move_progress = maxf(move_progress - speed * delta, move_progress_target)
		if move_pos[0] != move_pos[1]:
			position = move_pos[0].lerp(move_pos[1], move_progress)
		if move_rot != Vector3.ZERO:
			rotation = Vector3.ZERO.lerp(move_rot, move_progress)
