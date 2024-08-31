extends Node
class_name Movement_Data

@export_subgroup("speed")
@export var WALK_SPEED                  : float = 6
@export var CROUCH_SPEED                : float = 2
@export var DASH_SPEED                  : float = 8
@export var MAX_SPEED                   : float = 40
@export var JUMP_FORCE                  : float = 8

@export_subgroup("accelration")
@export var RUN_ACCEL                   : float = 7
@export var RUN_DECEEL                  : float = 4
@export var AIR_MAX_SPEED               : float = 15
@export var AIR_ADD_SPEED               : float = 2
@export var AIR_ACCEL                   : float = 70
@export var AIR_DECCEL                  : float = 1
@export var AIR_CAP                     : float = 1
@export var STAND_FRICTION              : float = 5.5
@export var CROUCH_FRICTION             : float = 2

@export_subgroup("crouch")
@export var CROUCH_ACCEL                : float = 7
@export var CROUCH_AIR_ADD_SPEED        : float = 5
@export var CROUCH_AIR_ACCEL            : float = 8
@export var CROUCH_AIR_DECCEL           : float = 1
@export var CROUCH_HEIGHT               : float = .8
@export var CAMERA_HEIGHT               : float = 1.2
var stand_height                        : float = 1.6 #player's collision height

@export_subgroup("slope")
@export var SLOPE_LIMIT                 : float = 0.785

@export_subgroup("sensitrivity")
@export_range(0.1,10.00,0.01)  var MOUSE_SENSITRIVITY :float = 1

@export_subgroup("Debug")
@onready var player                             = $".."
@export var gravity                             = 32
@export var gravity_precent             : float = .7
@export var accel_precent               : float = 1
@export var air_accel_precent           : float = 1
@export var friction_precent            : float = 1
@export var auto_bunny                  :  bool = false
var on_floor                            :  bool = false
