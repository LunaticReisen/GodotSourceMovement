extends Node

class_name Player_Physic

@onready var _data  = $"../Movement_Data"
@onready var camera = $"../Root/Head/Camera"

var step_height: Vector3
var step_incremental_check_height: Vector3
var stair_stepping_in_air


class Step_Result:
	var position: Vector3 = Vector3.ZERO
	var normal: Vector3 = Vector3.ZERO
	var is_step_up: bool = false

func air_accelerate(vel : Vector3,wish_dir : Vector3, wish_speed : float, accel : float, delta):     #air accel
	# clamp speed
	wish_speed = min(wish_speed,_data.AIR_CAP)
	var _currentspeed : float = vel.dot(wish_dir)
	var addspeed : float = wish_speed - _currentspeed
	
	if(addspeed <= 0):
		return vel
		
	var accelspeed : float = accel * wish_speed * delta

	accelspeed = min(accelspeed,addspeed)
	for i in range(3):
		vel += accelspeed * wish_dir * _data.air_accel_precent

	return vel

func accelerate(vel : Vector3,wish_dir : Vector3, wish_speed : float, accel : float, is_crouching :bool, delta): #ground accel
	var accelspeed : float
	var accel_precent :float = _data.accel_precent

	if (vel.length() >= _data.MAX_SPEED):
		return vel

	if (is_crouching):
		if (_data.on_floor):
			accelspeed = _data.CROUCH_ACCEL
		else :
			accelspeed = _data.CROUCH_AIR_ACCEL

	var _currentspeed : float = vel.dot(wish_dir)
	var addspeed : float = wish_speed - _currentspeed
	if(addspeed <= 0):
		return vel
	accelspeed = accel * delta * wish_speed
	if(accelspeed > addspeed):
		accelspeed = addspeed
	
	#little "boost"
	if (_data.player.velocity.length() > 15):
		accel_precent = .45

	vel += accelspeed * wish_dir * _data.accel_precent
	
	return vel

func handel_friction(vel : Vector3, t : float, is_crouching : bool, delta):
	var vec : Vector3 = vel
	vec.y = 0
	var speed : float = vec.length()
	var drop :float = 0
	var _friction

	if (is_crouching):
		_friction = _data.CROUCH_FRICTION
	else :
		_friction = _data.STAND_FRICTION

	if(_data.on_floor):
		var control :float 
		if (speed < _data.RUN_DECEEL):
			control = _data.RUN_DECEEL
		else :
			control = speed
		drop = control * _friction * delta * t * _data.friction_precent
	
	var newspeed : float = speed - drop
	
	if (newspeed < 0) :
		newspeed = 0
	if (speed > 0) : 
		newspeed /= speed
		
	_data.player.player_friction = newspeed #debug
	vel *= newspeed

	return vel


# step function
func step_check(delta: float , is_jumping: bool , result: Step_Result) -> bool:
	var is_step : bool = false
	
	return false
	pass



func get_movement_axis():
	#Initialize
	var basis = camera.global_transform.basis
	var dir = Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		dir -= basis.x
	if Input.is_action_pressed("move_right"):
		dir += basis.x
	if Input.is_action_pressed("move_forward"):
		dir -= basis.z
	if Input.is_action_pressed("move_back"):
		dir += basis.z
	dir.y = 0
	# dir -= basis.x
	dir = dir.normalized()
	return dir
