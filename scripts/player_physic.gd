extends Node

class_name Player_Physic

@onready var camera = $"../Root/Head/Camera"

var step_height: Vector3
var step_incremental_check_height: Vector3
var stair_stepping_in_air
var data = Global.player_data

class Step_Result:
	var position: Vector3 = Vector3.ZERO
	var normal: Vector3 = Vector3.ZERO
	var is_step_up: bool = false

func air_accelerate(vel : Vector3,wish_dir : Vector3, wish_speed : float, accel : float, delta):     #air accel
	# clamp speed
	wish_speed = min(wish_speed,Global.player_data.AIR_CAP)
	var _currentspeed : float = vel.dot(wish_dir)
	var addspeed : float = wish_speed - _currentspeed
	
	if(addspeed <= 0):
		return vel
		
	var accelspeed : float = accel * wish_speed * delta

	accelspeed = min(accelspeed,addspeed)
	for i in range(3):
		vel += accelspeed * wish_dir * Global.player_data.air_accel_precent

	return vel

func accelerate(vel : Vector3,wish_dir : Vector3, wish_speed : float, accel : float, is_crouching :bool, delta): #ground accel
	var accelspeed : float
	var accel_precent :float = Global.player_data.accel_precent

	if (vel.length() >= Global.player_data.MAX_SPEED):
		return vel

	if (is_crouching):
		if (Global.player_data.on_floor):
			accelspeed = Global.player_data.CROUCH_ACCEL
		else :
			accelspeed = Global.player_data.CROUCH_AIR_ACCEL

	var _currentspeed : float = vel.dot(wish_dir)
	var addspeed : float = wish_speed - _currentspeed
	if(addspeed <= 0):
		return vel
	accelspeed = accel * delta * wish_speed
	if(accelspeed > addspeed):
		accelspeed = addspeed
	
	#little "boost"
	if (Global.player.velocity.length() > 15):
		accel_precent = .45

	vel += accelspeed * wish_dir * Global.player_data.accel_precent
	
	return vel

func handel_friction(vel : Vector3, t : float, is_crouching : bool, delta):
	var vec : Vector3 = vel
	vec.y = 0
	var speed : float = vec.length()
	var drop :float = 0
	var _friction

	if (is_crouching):
		_friction = Global.player_data.CROUCH_FRICTION
	else :
		_friction = Global.player_data.STAND_FRICTION

	if(Global.player_data.on_floor):
		var control :float 
		if (speed < Global.player_data.RUN_DECEEL):
			control = Global.player_data.RUN_DECEEL
		else :
			control = speed
		drop = control * _friction * delta * t * Global.player_data.friction_precent
	
	var newspeed : float = speed - drop
	
	if (newspeed < 0) :
		newspeed = 0
	if (speed > 0) : 
		newspeed /= speed
		
	Global.player.player_friction = newspeed #debug
	vel *= newspeed

	return vel


# step function
func step_check(delta: float , is_jumping: bool , vel: Vector3 , result: Step_Result) -> bool:
	var is_step : bool = false
	step_height = data.STEP_HEIGH_DEFAULT
	step_incremental_check_height = data.STEP_HEIGH_DEFAULT / data.STEP_CHECK_COUNT

	# if !data.on_floor and is_stepping_in_air:
		# pass

	if vel.y >= 0 :
		for i in range(data.STEP_CHECK_COUNT):
			var test_motion_result : PhysicsTestMotionResult3D  = PhysicsTestMotionResult3D.new()
			var step_height :Vector3 = step_height - i * step_incremental_check_height
			var transfrom3d : Transform3D = get_node("..").global_transform
			var motion :Vector3 = step_height
			var test_motion_params : PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()

			test_motion_params.from = transfrom3d
			test_motion_params.motion = motion

			var is_collided :bool = PhysicsServer3D.body_test_motion(get_node("..").get_rid(), test_motion_params , test_motion_result)
			
			if is_collided and test_motion_result.get_collision_normal().y < 0 :
				continue

			#--------

			transfrom3d.origin += step_height
			motion = vel * delta

			test_motion_params.from = transfrom3d
			test_motion_params.motion = motion

			is_collided = PhysicsServer3D.body_test_motion(get_node("..").get_rid(), test_motion_params , test_motion_result)

			if !is_collided:
				transfrom3d.origin += motion
				motion = -step_height
				test_motion_params.from = transfrom3d
				test_motion_params.motion = motion

				is_collided = PhysicsServer3D.body_test_motion(get_node("..").get_rid(), test_motion_params , test_motion_result)

			if is_collided:
				if test_motion_result.get_collision_normal().angle_to(Vector3.UP) <= deg_to_rad(data.STEP_MAX_SLOPE_DEGREED):
					is_step = true

					result.is_step_up = true

					result.position = -test_motion_result.get_remainder()
					result.normal = test_motion_result.get_collision_normal()

					break







	return false



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
