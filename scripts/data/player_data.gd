extends Node
class_name Player_Datas

func _ready():
	Global.player_data = self

@export_subgroup("speed")
@export var WALK_SPEED                  : float = 6
@export var CROUCH_SPEED                : float = 2
@export var DASH_SPEED                  : float = 8
@export var GROUND_MAX_SPEED            : float = 40
@export var FLOAT_MAX_SPEED             : float = 20
@export var JUMP_FORCE                  : float = 7
@export var LADDER_SPEED                : float = 5
@export var SWIM_SPEED                  : float = 4
@export var SWIM_UP_SPEED               : float = 5

@export_subgroup("accelration")
@export var RUN_ACCEL                   : float = 8
@export var SWIM_ACCEL                   : float = 4
@export var RUN_DECEEL                  : float = 4
@export var SWIM_DECEEL                  : float = 3.5
@export var AIR_MAX_SPEED               : float = 15
@export var AIR_ADD_SPEED               : float = 2
@export var AIR_ACCEL                   : float = 70
@export var AIR_DECCEL                  : float = 1
@export var GROUND_AIR_CAP              : float = .5
@export var SURF_AIR_CAP                : float = 2
@export var STAND_FRICTION              : float = 5.5
@export var WATER_FRICTION              : float = 3.5
@export var CROUCH_FRICTION             : float = 2

@export_subgroup("crouch")
@export var CROUCH_ACCEL                : float = 7
@export var CROUCH_AIR_ADD_SPEED        : float = 5
@export var CROUCH_AIR_ACCEL            : float = 8
@export var CROUCH_AIR_DECCEL           : float = 1
@export var CROUCH_HEIGHT               : float = .7
@export var CAMERA_HEIGHT               : float = 1.2
@export var stand_height                : float = 1.5 #player's collision height

@export_subgroup("slope")
@export var SLOPE_LIMIT                 : float = 45

@export_subgroup("sensitrivity")
@export_range(0.1,10.00,0.01)  var MOUSE_SENSITRIVITY :float = 1

@export_subgroup("Grab")
@export var grab_up                     :  bool = false
@export var view_lock                   :  bool = false
@export var grab_power                  : float = 8.0
@export var rotation_power              : float = 0.05
@export var throw_power                 : float = 3
@export var distance_power              : float = 0.05 
@export var push_power	                : float = 1

@export_subgroup("(old)Step")
# @export var STEP_SPEED : float = 4
@export var STEP_DOWN_MARGIN : float = .09
@export var STEP_HEIGHT_DEFAULT : Vector3 = Vector3(0 , 0.6 , 0)
@export var STEP_HEIGHT_IN_AIR_DEFAULT : Vector3 = Vector3(0 , 0.6 , 0)
@export var STEP_MAX_SLOPE_DEGREED : float = 45
@export var STEP_CHECK_COUNT : int = 2
@export var WALL_MARGIN : float = 1
@export var STAIRS_FEELING_COEFFICIENT : float = 2.5

@export_subgroup("Step")
@export var MAX_STEP_HEIGHT : float = 0.3
@export var MAX_CROUCH_STEP_HEIGHT : float = 0.6
@export var snap_stair_last_frame := false
@export var last_frame_on_floor = -INF

@export_subgroup("Debug")
@export var gravity                             = 22.4
@export var gravity_precent             : float = 1
@export var gravity_water_precent       : float = 1
@export var accel_precent               : float = 1
@export var air_accel_precent           : float = 1
@export var air_move_precent            : float = .75
@export var friction_precent            : float = 1
@export var swim_gravity_precent        : float = .2
@export var swim_up_precent             : float = 2
@export var camera_smooth_amount        : float = .7
@export var ladder_invent               :   int = 1
@export var AIR_CAP                     : float = .5
var auto_bunny                          :  bool = false
var step_switch                         :  bool = false
var accel_switch                        :  bool = true
var camera_smooth_switch                :  bool = true
var on_floor                            :  bool = false
var snap_down_floor_switch              :  bool = true
var _snap_down_floor                    :  bool = false 
var ladder_boosting                     :  bool = true
var _floor_margin                       : float = 0.001
var camera_smooth_pos                           = null
var camera_smooth_lock                  :  bool = false