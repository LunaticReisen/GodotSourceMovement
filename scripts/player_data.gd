class_name Player_Data
extends Node

func _ready():
	Global.player_data = self


@export_subgroup("Debug")
@onready var player                             = %Player
@export var gravity                             = 32
@export var gravity_precent             : float = .7
@export var accel_precent               : float = 1
@export var air_accel_precent           : float = 1
@export var friction_precent            : float = 1
@export var auto_bunny                  :  bool = false
var on_floor                            :  bool = false
