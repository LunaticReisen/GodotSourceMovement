extends Node

class_name Movement_Data

@export_subgroup("speed")
@export var AIR_ADD_SPEED        :float = 4
@export var WALK_SPEED           :float = 4
@export var CROUCH_SPEED         :float = 1.5
@export var DASH_SPEED           :float = 6
@export var MAX_SPEED            :float = 20
@export var JUMP_FORCE           :float = 10

@export_subgroup("accelration")
@export var RUN_ACCEL            :float = 8
@export var RUN_DECEEL           :float = 6
@export var STARFE_SPEED         :float = 2
@export var AIR_ACCEL            :float = 2
@export var AIR_DECCEL           :float = 2
@export var AIR_CONTROL          :float = 0.3
@export var STAND_FRICTION       :float = 3.5
@export var CROUCH_FRICTION      :float = 1
@export var SURFACE_FRICTION     :float = 1

@export_subgroup("crouch")
#@export var CROUCH_MAX_SPEED:float = 3
@export var CROUCH_AIR_ADD_SPEED : float = 4
@export var CROUCH_HEIGHT        : float = .8
@export var CAMERA_HEIGHT        : float = 1.2
var stand_height                 : float = 1.4 #player's collision height

@export_subgroup("slope")
@export var SLOPE_LIMIT          : float = 45   # TODO

@export_subgroup("sensitrivity")
@export var MOUSE_SENSITRIVITY = 2
#TODO: CONTROLLER SUPPORT
var CONTORLLER_SENSITRIVITY = 700

@export_subgroup("Debug")
@export var _air_controlAdditionForward :float = 32
@export var gravity = 32
@export var gravity_precent : float = 1
@export var friction_precent : float = 1
@export var auto_bunny : bool = true

