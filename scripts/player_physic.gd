extends Node

class_name Player_Physic

@onready var camera = $"../Root/Head/StairsSmooth/Camera"

var step_height: Vector3
var step_incremental_check_height: Vector3
@onready var stairs_ahead_ray : RayCast3D = $"../StairsAHeadRay"
@onready var stairs_below_ray : RayCast3D = $"../StairsBelowRay"
@onready var stairs_smooth = $"../Root/Head/"
# var stair_stepping_in_air
# var result : PhysicsTestMotionResult3D

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

func is_too_steep(normal : Vector3) -> bool :
	return normal.angle_to(Vector3.UP) > Global.player_data.SLOPE_LIMIT 

func check_snap_to_stairs() :
	var is_snap := false
	# if lower ray cast colliding , and collider normal >= slope limit deg , will return true
	var floor_below : bool = stairs_below_ray.is_colliding() and !is_too_steep(stairs_below_ray.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - Global.player_data.last_frame_on_floor == 1
	
	if !Global.player_data.on_floor and Global.player.vel.y <= 0 and (was_on_floor_last_frame or is_snap) and floor_below:
		var _result = PhysicsTestMotionResult3D.new()
		if body_test_motion_own(Global.player.global_transform , Vector3(0, - Global.player_data.MAX_STEP_HEIGHT , 0) , _result):
			save_camera_pos()
			Global.player.position.y += _result.get_travel().y
			apply_floor_snap_own()
			is_snap = true
	Global.player_data.snap_stair_last_frame = is_snap

func check_snap_up_stair(delta) -> bool :
	if !Global.player_data.on_floor and !Global.player_data.snap_stair_last_frame :
		return false

	# only need x and z position
	var expected_motion = Global.player.vel * Vector3(1,0,1) * delta

	# translated: return transform move to offset 's transform(?)
	var step_pos_with_clearance = Global.player.global_transform.translated(expected_motion + Vector3(0 , Global.player_data.MAX_STEP_HEIGHT * 2 , 0))
	var _result = PhysicsTestMotionResult3D.new()

	# if test success and collided sb3d or cgs object will continue 
	if body_test_motion_own(step_pos_with_clearance , Vector3(0 , -Global.player_data.MAX_STEP_HEIGHT * 2 , 0) , _result) and (_result.get_collider().is_class("StaticBody3D") or _result.get_collider().is_class("CSGShape3D")):
		
		# print(_result.get_collision_normal().angle_to(Vector3.UP))
		# if !is_too_steep(_result.get_collision_normal()) or (is_too_steep(stairs_ahead_ray.get_collision_normal()) and is_too_steep(stairs_below_ray.get_collision_normal())):
		# 	return false

		var collide_step_height = ((step_pos_with_clearance.origin + _result.get_travel()) - Global.player.global_position).y

		#if collide too high or too low or greater than max step height will return
		if collide_step_height > Global.player_data.MAX_STEP_HEIGHT or collide_step_height <= 0.01 or (_result.get_collision_point() - Global.player.global_position).y > Global.player_data.MAX_STEP_HEIGHT:
			return false

		stairs_ahead_ray.global_position = _result.get_collision_point() + Vector3(0, Global.player_data.MAX_STEP_HEIGHT ,0) + expected_motion.normalized() * 0.1
		stairs_ahead_ray.force_raycast_update()

		# if collided object and not too steep will return true
		# it will plus the offset on the player global position , and then snap
		if stairs_ahead_ray.is_colliding() and !is_too_steep(stairs_ahead_ray.get_collision_normal()):
			save_camera_pos()
			Global.player.global_position = step_pos_with_clearance.origin+ _result.get_travel()
			apply_floor_snap_own()
			Global.player_data.snap_stair_last_frame = true
			return true
	return false

# apply_floor_snap from cb3d , I just reworte it
func apply_floor_snap_own():
	var add_vel :Vector3
	if Global.player_data.on_floor :
		return
	
	var params = PhysicsTestMotionParameters3D .new()
	params.max_collisions = 4
	params.recovery_as_collision = true
	params.collide_separation_ray = true

	var _result = Global.player.move_and_collide(Global.player.vel,true)

	if _result:
		if _result.get_collider() != null:
			if _result.get_travel().length() > Global.player_data._floor_margin:
				add_vel = Vector3.UP * Vector3.UP.dot(_result.get_travel())
			else :
				add_vel = Vector3.ZERO
			
			Global.player.global_position += add_vel

func body_test_motion_own(from : Transform3D , motion : Vector3 , result : PhysicsTestMotionResult3D) -> bool:
	var params = PhysicsTestMotionParameters3D.new()

	params.from = from
	params.motion = motion

	return PhysicsServer3D.body_test_motion(Global.player.get_rid() , params , result)

func save_camera_pos() :
	if Global.player_data.camera_smooth_pos == null:
		Global.player_data.camera_smooth_pos = stairs_smooth.global_position

func camera_smooth(delta) :
	##TODO:镜头平滑但是不平滑
		##原因：我的镜头是旋转父节点的，但是以下代码是基于旋转镜头本身的
		##需要转换坐标
		##目前解决方法：直接修改为修改head节点
	if Global.player_data.camera_smooth_pos == null : 
		return
	stairs_smooth.global_position.y = Global.player_data.camera_smooth_pos.y
	stairs_smooth.position.y = clampf(stairs_smooth.position.y , -Global.player_data.camera_smooth_amount , Global.player_data.camera_smooth_amount)
	var move_amount = max(Global.player.vel.length() * delta , Global.player.currentspeed / 2 * delta)
	# var move_amount = max(Global.player.vel.length() * delta , Global.player.vel.length() / 2 * delta)
	stairs_smooth.position.y = move_toward(stairs_smooth.position.y , 0.0 , move_amount*.8)
	Global.player_data.camera_smooth_pos = stairs_smooth.global_position
	if stairs_smooth.position.y == 0:
		Global.player_data.camera_smooth_pos = null

#Initialize
func get_movement_axis():
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
