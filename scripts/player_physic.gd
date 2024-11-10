extends Node

class_name Player_Physic

@onready var camera = $"../Root/Head/StairsSmooth/Camera"

var step_height: Vector3
var step_incremental_check_height: Vector3
@onready var stairs_ahead_ray : RayCast3D = $"../StairsAHeadRay"
@onready var stairs_below_ray : RayCast3D = $"../StairsBelowRay"
@onready var head = $"../Root/Head/"
var _ladder_climbing :Area3D = null
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

func accelerate(vel : Vector3,wish_dir : Vector3, wish_speed : float, accel : float, delta): #ground accel
	var accelspeed : float
	var accel_precent :float = Global.player_data.accel_precent

	if (vel.length() >= Global.player_data.GROUND_MAX_SPEED):
		return vel

	if (Global.player.is_crouching):
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
	if (vel.length() > 15):
		accel_precent = .45

	vel += accelspeed * wish_dir * accel_precent
	
	return vel

func water_accelerate(vel : Vector3,wish_dir : Vector3, wish_speed : float, accel : float, delta): #water accel
	var accelspeed : float
	var accel_precent :float = Global.player_data.accel_precent
	if (vel.length() >= Global.player_data.GROUND_MAX_SPEED):
		return vel
	accelspeed = Global.player_data.SWIM_ACCEL
	var _currentspeed : float = vel.dot(wish_dir)
	var addspeed : float = wish_speed - _currentspeed
	if(addspeed <= 0):
		return vel
	accelspeed = accel * delta * wish_speed
	if(accelspeed > addspeed):
		accelspeed = addspeed
	
	# little "boost"
	if (vel.length() > 5):
		accel_precent = .2
	vel.x += accelspeed * wish_dir.x * accel_precent
	vel.y += accelspeed * wish_dir.y * accel_precent * .5
	vel.z += accelspeed * wish_dir.z * accel_precent
	if vel.y > Global.player_data.FLOAT_MAX_SPEED:
		vel.y = Global.player_data.FLOAT_MAX_SPEED
	
	return vel

func handel_friction(vel : Vector3, t : float, is_in_water : bool, delta):
	var vec : Vector3 = vel
	vec.y = 0
	var speed : float = vec.length()
	var drop :float = 0
	var _friction

	if (Global.player.is_crouching):
		_friction = Global.player_data.CROUCH_FRICTION
	else :
		_friction = Global.player_data.STAND_FRICTION

	if is_in_water:
		_friction = Global.player_data.WATER_FRICTION


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
	if !is_in_water:
		vel *= newspeed
	else :
		vel.x *= newspeed
		vel.z *= newspeed

	return vel

func handel_ladder() -> bool :
	var was_climbing_ladder := _ladder_climbing and _ladder_climbing.overlaps_body(Global.player)
	if !was_climbing_ladder:
		_ladder_climbing = null
		for ladder in get_tree().get_nodes_in_group("ladder") :
			if ladder.overlaps_body(Global.player):
				_ladder_climbing = ladder
				break
	if _ladder_climbing == null:
		return false
	
	var ladder_global_transform : Transform3D = _ladder_climbing.global_transform
	var pos_relative_to_ladder = ladder_global_transform.affine_inverse() * Global.player.global_position
	
	#separate the movement and multiply the head transform
	var forward := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var side := Input.get_action_strength("move_right") - Input.get_action_strength("move_left") 

	var ladder_forward_move = ladder_global_transform.affine_inverse().basis * head.global_transform.basis * Vector3(0 , 0 , -forward)
	var ladder_side_move = ladder_global_transform.affine_inverse().basis * head.global_transform.basis * Vector3(side , 0 , 0)
	
	var ladder_strafe_vel : float = Global.player_data.LADDER_SPEED * (ladder_forward_move.x + ladder_side_move.x)
	var ladder_climb_vel : float = Global.player_data.LADDER_SPEED * -ladder_side_move.z

	var cam_forward_amount : float = head.basis.z.dot(_ladder_climbing.basis.z)
	var up_wish := Vector3.UP.rotated(Vector3(0,1,0) ,deg_to_rad(-45 * cam_forward_amount)).dot(ladder_forward_move)
	ladder_climb_vel += Global.player_data.LADDER_SPEED * up_wish

	var should_dismount = false

	#top marker : climbing to the top will force player get off the ladder
	if ! was_climbing_ladder:
		var mounting_from_top = pos_relative_to_ladder.y > _ladder_climbing.get_node("TopLadder").position.y
		if mounting_from_top :
			if ladder_climb_vel > 0:
				should_dismount = true
		else :
			if (ladder_global_transform.affine_inverse().basis * Vector3(Global.player.dir.x ,0 ,Global.player.dir.y)).z >= 0 :
				should_dismount = true

		if abs(pos_relative_to_ladder.z) > 0.1 :
			should_dismount = true

	if Global.player_data.on_floor and ladder_climb_vel <= 0 :
		should_dismount = true
 
	if should_dismount :
		_ladder_climbing = null 
		return false

	#jumping handle
	if was_climbing_ladder and Input.is_action_just_pressed("jump"):

		#Add a invent to fix the trenchbroom mapping's problem
		if _ladder_climbing.get_child(1).shape is ConvexPolygonShape3D :
			Global.player.vel = _ladder_climbing.global_transform.basis.z * Global.player_data.JUMP_FORCE * 1
			Global.player.velocity = Global.player.vel
		else :
			Global.player.vel = _ladder_climbing.global_transform.basis.z * Global.player_data.JUMP_FORCE * 1
			Global.player.velocity = Global.player.vel
		_ladder_climbing = null
		return false

	Global.player.vel = ladder_global_transform.basis * Vector3(ladder_strafe_vel , ladder_climb_vel , 0)

	#ladder boosting
	if !Global.player_data.ladder_boosting :
		Global.player.vel = Global.player.vel.limit_length(Global.player_data.LADDER_SPEED)

	pos_relative_to_ladder.z = 0
	Global.player.global_position = _ladder_climbing.global_transform * pos_relative_to_ladder

	Global.player.velocity = Global.player.vel

	Global.player.move_and_slide_own()
	
	return true

# stairs function
func check_snap_to_stairs() :
	var is_snap := false
	# if lower ray cast colliding , and collider normal >= slope limit deg , will return true
	var floor_below : bool = stairs_below_ray.is_colliding() and !is_too_steep(stairs_below_ray.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - Global.player_data.last_frame_on_floor == 1
	
	if !Global.player_data.on_floor and Global.player.vel.y <= 0 and (was_on_floor_last_frame or is_snap) and floor_below:
		var _result = PhysicsTestMotionResult3D.new()
		if body_test_motion_own(Global.player.global_transform , Vector3(0, - Global.player_data.MAX_STEP_HEIGHT , 0) , _result):
			save_camera_pos()
			Global.player.position.y += _result.get_travel().y*1
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
		var collide_step_height = ((step_pos_with_clearance.origin + _result.get_travel()) - Global.player.global_position).y

		#if collide too high or too low or greater than max step height will return
		if collide_step_height > Global.player_data.MAX_STEP_HEIGHT or collide_step_height <= 0.01:
			if (_result.get_collision_point() - Global.player.global_position).y > Global.player_data.MAX_STEP_HEIGHT:
				return false
			elif Global.player.is_crouching or Global.player.is_on_crouching:
				if !(_result.get_collision_point() - Global.player.global_position).y > Global.player_data.MAX_CROUCH_STEP_HEIGHT:
					return false

		stairs_ahead_ray.global_position = _result.get_collision_point() + Vector3(0, Global.player_data.MAX_STEP_HEIGHT ,0) + expected_motion.normalized() * 0.1
		stairs_ahead_ray.force_raycast_update()

		# if collided object and not too steep will return true
		# it will plus the offset on the player global position , and then snap
		if stairs_ahead_ray.is_colliding() and !is_too_steep(stairs_ahead_ray.get_collision_normal()):
			save_camera_pos()
			Global.player.global_position = step_pos_with_clearance.origin+ _result.get_travel()
			# one more smooth , because this if else switch, otherwise will looks fucking bounce
			if Global.player_data.camera_smooth_switch:
				camera_smooth(delta)
			apply_floor_snap_own()
			Global.player_data.snap_stair_last_frame = true
			return true
	return false

# stairs camer smooth function
func save_camera_pos() :
	if Global.player_data.camera_smooth_pos == null:
		Global.player_data.camera_smooth_pos = head.global_position

func camera_smooth(delta) :
	if Global.player_data.camera_smooth_pos == null : 
		return
	head.global_position.y = Global.player_data.camera_smooth_pos.y
	head.position.y = clampf(head.position.y , -Global.player_data.camera_smooth_amount , Global.player_data.camera_smooth_amount)
	var move_amount = max(Global.player.vel.length() * delta , Global.player.currentspeed / 2 * delta)
	head.position.y = move_toward(head.position.y , 0.0 , move_amount)
	Global.player_data.camera_smooth_pos = head.global_position
	if head.position.y == 0:
		Global.player_data.camera_smooth_pos = null

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

func is_too_steep(normal : Vector3) -> bool :
	if Global.player.is_crouching or Global.player.is_on_crouching:
		return normal.angle_to(Vector3.UP) > Global.player_data.SLOPE_LIMIT 
	else :
		return normal.angle_to(Vector3.UP) > Global.player_data.SLOPE_LIMIT 


#Initialize
func get_movement_axis():
	var basis = camera.global_transform.basis
	var dir = Vector3.ZERO
	if Input.get_action_strength("move_left"):
		dir -= basis.x
	if Input.get_action_strength("move_right"):
		dir += basis.x
	if Input.get_action_strength("move_forward"):
		dir -= basis.z
	if Input.get_action_strength("move_back"):
		dir += basis.z
	dir.y = 0
	dir = dir.normalized()
	return dir
