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
