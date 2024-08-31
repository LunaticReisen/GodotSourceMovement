class_name Player_Data
extends Node

func _ready():
	Global.player_data = self


@export_subgroup("Grab")
@export var grab_up                     :  bool = false
@export var view_lock                   :  bool = false
@export var grab_power                  : float = 8.0
@export var rotation_power              : float = 0.05
@export var throw_power                 : float = 3
@export var distance_power              : float = 0.05
@export var push_power	                : float = 1

@export_subgroup("Step")
@export var STEP_DOWN_MARGIN : float = 0.001
@export var STEP_HEIGH_DEFAULT : float = 0.01
@export var STEP_HEIGHT_IN_AIR_DEFAULT : Vector3 = Vector3(0 , 0.6 , 0)
@export var STEP_MAX_SLOPE_DEGREED : float = 40.0
@export var STEP_CHECK_COUNT : int = 2
@export var WALL_MARGIN : float = 0.001
@export var STAIRS_FEELING_COEFFICIENT : float = 2.5
