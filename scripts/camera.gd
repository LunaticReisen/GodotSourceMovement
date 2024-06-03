extends Node3D

@onready var root_character : CharacterBody3D = get_parent().get_parent()
@onready var _data : Movement_Data = $"../../Movement_Data"
# Called when the node enters the scene tree for the first time.

func _input(event):
	if !Global.player_data.view_lock:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			root_character.rotate_y(deg_to_rad(event.relative.x * _data.MOUSE_SENSITRIVITY * 0.1 * -1))
			rotate_x(deg_to_rad(event.relative.y * _data.MOUSE_SENSITRIVITY * 0.1 * -1))
			rotation.x = clamp(rotation.x, -1.3, 1.3)
