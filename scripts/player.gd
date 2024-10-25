extends CharacterBody3D

#region debug
@onready var collider :CollisionShape3D = $PlayerCollider		#collider
@onready var collider_shape 									#collider shape
@onready var ceilingcast :ShapeCast3D = $Root/CeilingCast		#raycast
@onready var player_physic : Player_Physic = $Player_Physic		#player_physic
@onready var head = $Root
@onready var stairs_smooth = $Root/Head/StairsSmooth
@onready var stairs_ahead_ray : RayCast3D = $"StairsAHeadRay"
@onready var stairs_below_ray : RayCast3D = $"StairsBelowRay"


var pos : Vector3
var topspeed :float = 0
var _wishspeed :float = 0
var currentspeed : float = 0
var player_friction :float = 0
var movement_state = "what"
var last_movement_state = "what"

var vel : Vector3 = Vector3.ZERO
var DEBUG_origin_transform :Vector3
var DEBUG_wishdir :Vector3

var _wish_jump : bool = false 

var is_step : bool = false

var head_offset : Vector3 = Vector3.ZERO

#crouch var
var is_crouching : bool = false 
var is_on_crouching : bool = false 
var is_on_stand : bool = false 
var is_last_frame_collide :bool = false
var is_collide :bool = false
var collide :bool = false
var crouching :bool

var is_it_collide :bool

var raw_input
var dir
var floor_normal : float 

var is_stepping : bool 
var is_on_ladder :bool

var cam_aligned_wish_dir := Vector3.ZERO

#crouch timer
var t1 : float
var t2 : float
var t3 : float = 0

#endregion 

#hud signal
signal DEBUGING_

func _ready():
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DEBUG_origin_transform = global_position
	Global.player_data.on_floor = false
	
func _input(event):	
	if(Input.is_action_just_pressed("test_reset")):
		get_tree().reload_current_scene()
		# apply_floor_snap()
	if(Input.is_action_pressed("test_button_1")):
		player_physic.apply_floor_snap_own()
	
	# if event is InputEventMouseButton:
	# 	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed == true:
	# 		print("fuck")

func _physics_process(delta):

	if Global.player_data.on_floor : Global.player_data.last_frame_on_floor = Engine.get_physics_frames()

	debug_var()
	speed_changer()
	# We can let the magic come true , right?
	process_movement(delta)
	velocity = vel
	if !is_in_water():
		if !Global.player_data.step_switch:
			# if crouch, add some magic in y axis for those raycast
			if (is_crouching or is_on_crouching)and t3 == 0:
				t3 += 1
				stairs_ahead_ray.position.y += .3
				stairs_below_ray.position.y += .5
	
			if (is_on_stand or !is_crouching) and t3 == 1:
				t3 -= 1
				stairs_ahead_ray.position.y -= .5
				stairs_below_ray.position.y -= .3
	
			is_stepping = player_physic.check_snap_up_stair(delta)
			is_on_ladder = player_physic.handel_ladder()
			if !is_stepping:
				if !is_on_ladder:
					is_it_collide =move_and_slide_own()
					player_physic.check_snap_to_stairs()
					vel = velocity
					if Global.player_data.camera_smooth_switch:
						player_physic.camera_smooth(delta)
		else :
			# Let the magic come true
			is_it_collide =move_and_slide_own()
			vel = velocity
	else :
		is_it_collide =move_and_slide_own()
		vel = velocity

	crouching = handel_crouch(delta)
	handel_jump()

	#top speed calculation
	if (get_current_speed() > topspeed):
		topspeed = get_current_speed()
	
	if is_on_ladder or is_in_water():
		if get_current_speed_full() > topspeed:
			topspeed = get_current_speed_full()
	else :
		if get_current_speed() > topspeed:
			topspeed = get_current_speed()
	last_movement_state = movement_state

func process_movement(delta) -> void:
	raw_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")	#Initialize
	dir = player_physic.get_movement_axis()
	if !is_in_water():
		if (Global.player_data.on_floor):
			ground_move(delta)
			movement_state = "ground"
		else :
			air_move(delta)
			movement_state = "air"
	else:
		movement_state = "water"
		water_move(delta)

#See more in https://github.com/WiggleWizard/quake3-movement-unity3d/blob/master/CPMPlayer.cs
func ground_move(delta) -> void:
	Global.player_data.on_floor = true
	var accle : float
	if (!_wish_jump):
		vel = player_physic.handel_friction(vel,1,crouching,delta)
	else :
		vel = player_physic.handel_friction(vel,0,crouching,delta)		
	var wish_dir : Vector3 = Vector3(dir.x, 0, dir.z)
	DEBUG_wishdir = wish_dir
	wish_dir = wish_dir.normalized()
	var wish_speed : float = wish_dir.length()
	wish_speed *= currentspeed
	if (crouching):
		accle = Global.player_data.CROUCH_ACCEL
	else :
		accle = Global.player_data.RUN_ACCEL 

	vel = player_physic.accelerate(vel, wish_dir, wish_speed, accle, false, delta)

	if (_wish_jump):
		vel.y = Global.player_data.JUMP_FORCE
		_wish_jump = false

	_wishspeed = wish_speed

func water_move(delta) -> void:
	var stop_gravity :bool = true
	if last_movement_state == "air":
		vel.y *= 0.75
		stop_gravity = true
	else :
		stop_gravity = false
	var accle : float
	vel = player_physic.handel_water_friction(vel,1,delta)
	var wish_dir : Vector3 = %Camera.global_transform.basis * Vector3(raw_input.x , 0 , raw_input.y)
	DEBUG_wishdir = wish_dir
	wish_dir = wish_dir.normalized()
	var wish_speed : float = wish_dir.length()
	wish_speed *= currentspeed
	accle = Global.player_data.SWIM_ACCEL 
	

	if !Global.player_data.on_floor and !_wish_jump and wish_dir.y == 0 and !stop_gravity:
		vel.y -= Global.player_data.gravity * delta * Global.player_data.gravity_precent * Global.player_data.swim_gravity_precent
	
	if stop_gravity:
		vel.y += Global.player_data.gravity * delta * 10

	vel = player_physic.accelerate(vel, wish_dir, wish_speed, accle, true, delta)
	
	if _wish_jump:
		vel.y += Global.player_data.SWIM_UP_SPEED * delta * Global.player_data.swim_up_precent
	

	_wishspeed = wish_speed


func air_move(delta) -> void:
	var accel : float
	var add_speed :float 
	var _wishvel : float= Global.player_data.AIR_ACCEL
	var wish_dir : Vector3	 = Vector3(dir.x, 0, dir.z).normalized() * Global.player_data.air_move_precent
	var wish_speed :float = wish_dir.length()
	DEBUG_wishdir = wish_dir

	if(is_crouching):
		add_speed = Global.player_data.CROUCH_AIR_ADD_SPEED
	else :
		add_speed = Global.player_data.AIR_ADD_SPEED
	wish_speed *= add_speed

	if Global.player_data.accel_switch:
		if (wish_speed > Global.player_data.AIR_MAX_SPEED):
			wish_speed =Global.player_data.AIR_MAX_SPEED
		if (crouching):
			accel = Global.player_data.CROUCH_AIR_ACCEL
		else :
			accel = Global.player_data.AIR_ACCEL
	else :
		#left or right move to accelerate	
		if (raw_input.y == 0 and raw_input.x != 0):
			if (wish_speed > Global.player_data.AIR_MAX_SPEED):
				wish_speed =Global.player_data.AIR_MAX_SPEED
			if (crouching):
				accel = Global.player_data.CROUCH_AIR_ACCEL
			else :
				accel = Global.player_data.AIR_ACCEL
	
	#clamp the max speed
	if wish_speed != 0.0 and wish_speed > Global.player_data.AIR_MAX_SPEED:
		wish_speed = Global.player_data.AIR_MAX_SPEED
	
	vel = player_physic.air_accelerate(vel,wish_dir, wish_speed, accel, delta)
	
	vel.y -= Global.player_data.gravity * delta * Global.player_data.gravity_precent

	_wishspeed = wish_speed #debug

func is_in_water() -> bool:
	if get_tree().get_nodes_in_group("water_area").all(func(area): return !area.overlaps_body(Global.player)):
		return false
	return true

func handel_jump() -> void:

	if Global.player_data.step_switch:
		return

	if Input.is_action_pressed("jump") and is_in_water():
		_wish_jump = true
		return

	if Input.is_action_just_pressed("jump") && Global.player_data.on_floor:
		_wish_jump = true
		return
	
	# if auto bunny is on ,hold jump button will always jumpping ,unless released button
	if Global.player_data.auto_bunny and Input.is_action_pressed("jump"):
		if (_wish_jump == true):
			return
		else :
			_wish_jump = true
			return
	elif Global.player_data.auto_bunny and Input.is_action_just_released("jump"):
		_wish_jump = false
		return
	_wish_jump =false

func handel_crouch(delta) -> bool:
	collider_shape = collider.shape		#Player collider shape
	collide = ceilingcast.is_colliding()	#Initialize
	if (Input.is_action_pressed("crouch") or is_on_crouching):
		t1 += delta * 15	#smooth the position
		collider_shape.height = Global.player_data.CROUCH_HEIGHT		#control colldier height
		if (!collide):
			head.position.y = lerp(head.position.y,Global.player_data.CAMERA_HEIGHT,t1)	#control camera height
		is_on_crouching = true
		if(head.position.y >= Global.player_data.CAMERA_HEIGHT):
			if(head.position.y - Global.player_data.CAMERA_HEIGHT <= 0.01):
				head.position.y = Global.player_data.CAMERA_HEIGHT
			t1 = 0	#reset
			is_crouching = true
			is_on_crouching = false

	# handel standing	
	# if last frame collide something, it will not stand up
	if (is_crouching):	
		if (collide) :
			is_collide = true
		else :
			is_collide = false
		if (is_collide):
			is_last_frame_collide = is_collide
			return true
		elif (!is_collide) :
			if(Input.is_action_just_released("crouch") or is_on_stand) :
				#position.y += 0.55		#if you want a goldscr style jumping, ctrl+/ this line
				t2 += delta * 5		#smooth the position
				head.position.y = lerp(head.position.y,Global.player_data.stand_height,t2)		#control camera height
				collider_shape.height = Global.player_data.stand_height		#control colldier height
				is_on_stand = true
				is_last_frame_collide = is_collide
				if (head.position.y >= Global.player_data.stand_height) :
					t2 = 0		#reset
					is_on_stand = false
					is_crouching =false
					is_last_frame_collide = is_collide
			elif (is_last_frame_collide == true and Input.is_action_pressed("crouch")) : 
				return true
			elif (is_last_frame_collide == true and !Input.is_action_pressed("crouch")) : #just copy and paste
				#position.y += 0.55		#if you want a goldscr style jumping, ctrl+/ this line
				t2 += delta * 5		#smooth the position
				head.position.y = lerp(head.position.y,Global.player_data.stand_height,t2)		#control camera height
				collider_shape.height = Global.player_data.stand_height		#control colldier height
				is_on_stand = true
				is_last_frame_collide = is_collide

	if (is_crouching or is_on_crouching):
		return true
	else :
		return false

# https://www.reddit.com/r/godot/comments/16do5ua/move_and_slide_works_differently_between_35_and_4/

## Perform a move-and-slide along the set velocity vector. If the body collides
## with another, it will slide along the other body rather than stop immediately.
## The method returns whether or not it collided with anything.

func move_and_slide_own() -> bool:
	var collided := false

	# Reset previously detected floor
	Global.player_data.on_floor = false

	#check floor
	var checkMotion := velocity * (1/60.)
	checkMotion.y  -= Global.player_data.gravity * (1/360.)
		
	var testcol := move_and_collide(checkMotion, true)
	# print(testcol)
	if testcol:
		var testNormal = testcol.get_normal()
		floor_normal = testNormal.angle_to(up_direction)
		if (testNormal.angle_to(up_direction) < deg_to_rad(Global.player_data.SLOPE_LIMIT)):
			Global.player_data.on_floor = true
			# player_physic.apply_floor_snap_own()


	# Loop performing the move
	var motion = velocity * get_delta_time()

	for step in max_slides:
		
		var collision := move_and_collide(motion)

		if move_and_collide(motion,true) :
			var test : KinematicCollision3D = move_and_collide(motion,true)
			if test.get_collider() is RigidBody3D :
				# print(test.get_collider())
				var _p : float = 1
				# print(test.get_collider().mass)
				if test.get_collider().mass <1:
					_p = test.get_collider().mass * 5
				if test.get_collider().mass >1:
					_p = clamp(test.get_collider().mass * .5 , 0.1 , 1)
				test.get_collider().apply_central_impulse(-test.get_normal() * (_p * Global.player_data.push_power))
		
		if not collision:
			# No collision, so move has finished
			break

		# Calculate velocity to slide along the surface
		var normal = collision.get_normal()
		
		motion = collision.get_remainder().slide(normal)
		velocity = velocity.slide(normal)
		# Collision has occurred
		collided = true
	return collided

func speed_changer() -> void:
	if (Input.is_action_pressed("dash") and !is_crouching):
		currentspeed = Global.player_data.DASH_SPEED
	elif (is_crouching or is_on_crouching):
		currentspeed = Global.player_data.CROUCH_SPEED
	elif is_in_water():
		currentspeed = Global.player_data.SWIM_SPEED
		# currentspeed = currentspeed * .75
	else :
		currentspeed = Global.player_data.WALK_SPEED

func get_current_speed():
	pos = velocity
	pos.y = 0
	return pos.length()

func get_current_speed_full():
	return velocity.length()

func debug_var():
	Global.debug_panel.add_property("velocity", velocity ,1)
	Global.debug_panel.add_property("raw_input", raw_input ,2)
	Global.debug_panel.add_property("position", global_position ,3)
	Global.debug_panel.add_property("topspeed", topspeed ,4)
	Global.debug_panel.add_property("speed", get_current_speed() ,5)
	Global.debug_panel.add_property("on_floor", Global.player_data.on_floor ,6)
	Global.debug_panel.add_property("movement_state", movement_state ,7)
	Global.debug_panel.add_property("step", is_stepping , 8)
	Global.debug_panel.add_property("snap to stair last frame", Global.player_data.snap_stair_last_frame , 9)
	Global.debug_panel.add_property("ladder", is_on_ladder , 10)
	Global.debug_panel.add_property("water", is_in_water() , 11)
	Global.debug_panel.add_property("jump", _wish_jump , 12)
	Global.debug_panel.add_property("wish_dir", DEBUG_wishdir , 13)

func get_delta_time():
	if Engine.is_in_physics_frame():
		return get_physics_process_delta_time()
	return get_process_delta_time()

#trigger the area3d will put you up
func _on_area_3d_body_entered(body:Node3D) -> void:
	position = DEBUG_origin_transform

func _on_check_button_toggled(toggled_on : bool) -> void:
	if toggled_on:
		Global.player_data.auto_bunny = true
	if !toggled_on:
		Global.player_data.auto_bunny = false
