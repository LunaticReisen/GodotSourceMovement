# Ported from https://github.com/WiggleWizard/quake3-movement-unity3d/blob/master/CPMPlayer.cs
#Ref:
#https://github.com/AkimBowX2/Godot-4_FPS_controller/blob/main/scenes/player/player.gd
#https://github.com/WiggleWizard/quake3-movement-unity3d/blob/master/CPMPlayer.cs
#https://github.com/dwlcj/Godot-Strafe-Jumping/blob/main/Scenes/Player.gd#L161
#https://www.youtube.com/watch?v=v3zT3Z5apaM&t=165s
#https://adrianb.io/2015/02/14/bunnyhop.html
#https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c#L235

extends CharacterBody3D

#DEBUG
@export_subgroup("DEBUG")
#region debug
@onready var collider_shape :CollisionShape3D = $Collider		#collider
@onready var collider : CapsuleShape3D							#collider shape
@onready var ceilingcast :ShapeCast3D = $Root/CeilingCast		#raycast
@onready var _data : Movement_Data = $Movement_Data				#movement data
@onready var head = $Root

var pos : float
var topspeed :float = 0
var currentspeed : float
var player_friction :float = 0
var _friction :float
var vel_x : float
var last_frame_rotation : float

var vel : Vector3 = Vector3.ZERO
var appliedVelocity : Vector3
var DEBUG_origin_transform :Vector3
var DEBUG_wishdir :Vector3

var _wishJump : bool = false 
var is_crouching : bool = false 
var is_on_crouching : bool = false 
var is_on_stand : bool = false 
var mouse : bool = false 
var is_last_frame_collide :bool = false
var is_collide :bool = false
var collide :bool = false
var air_accel_switch :bool = false

var raw_input
var dir

#crouch timer
var t1 : float
var t2 : float
#endregion

#hud signal
signal DEBUGING_

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DEBUG_origin_transform = global_position
	
func _input(event):
	#default button "esc" & "left mouse"
	#CANT USE IDK WHY
	if(event.is_action_pressed("fire")):
		if (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().set_input_as_handled()
		mouse = true
	if(event.is_action_pressed("mouse_capture_exit")):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse = false		

func _physics_process(delta):
	DEBUG_FUNTION()
	speed_changer()
	process_movement(delta)
	
	appliedVelocity = velocity.lerp(vel, delta * 17)
	velocity = appliedVelocity
	move_and_slide()
	
	handel_jump()
	handel_crouch(delta)
	if(pos > topspeed):
		topspeed = pos 		#top speed calculation
	
func process_movement(delta) -> void:
	raw_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")	#Initialize
	dir = (transform.basis * Vector3(raw_input.x, 0 , raw_input.y)).normalized()	#Initialize
	if (is_on_floor()):
		ground_move(delta)
	else :
		air_move(delta)

#See more in https://github.com/WiggleWizard/quake3-movement-unity3d/blob/master/CPMPlayer.cs
func ground_move(delta) -> void:
	var wish_dir : Vector3
	if (!_wishJump):
		handel_friction(1,delta)
	else :
		handel_friction(0,delta)		
	wish_dir = Vector3(dir.x, 0, dir.z)
	DEBUG_wishdir = wish_dir
	wish_dir = wish_dir.normalized()
	var wish_speed : float = wish_dir.length()
	wish_speed *= currentspeed
	accelerate(wish_dir, wish_speed, _data.RUN_ACCEL, delta)
	
	#fix werid gravity problem, reset velocity.y
	if (is_on_floor()):
		vel.y = 0

	if (_wishJump):
		vel.y = _data.JUMP_FORCE
		_wishJump = false
	
	if (velocity.length() <= 0.1):
		velocity = Vector3.ZERO

func air_move(delta) -> void:
	# no more starfing on ceiling
	if (is_on_ceiling()):
		vel.y = 0
		vel.y -= _data.gravity * _data.gravity_precent * delta * 5	
	var wish_dir : Vector3	
	var _wishvel : float= _data.AIR_ACCEL
	var accel : float
	wish_dir = Vector3(dir.x, 0, dir.z)
	DEBUG_wishdir = wish_dir	
	var wish_speed :float = wish_dir.length()
	var add_speed :float 
	if(is_crouching):
		add_speed = _data.CROUCH_AIR_ADD_SPEED
	else :
		add_speed = _data.AIR_ADD_SPEED
	wish_speed *= add_speed
	wish_dir = wish_dir.normalized()
	if(vel.dot(wish_dir) < 0.0):
		accel = _data.AIR_DECCEL
	else :
		accel = _data.AIR_ACCEL
	#left or right move to accelerate	
	if (raw_input.y == 0.0 and abs(dir.x) > 0.0):
		if (wish_speed > _data.AIR_MAX_SPEED):
			wish_speed =_data.AIR_MAX_SPEED
		accel = _data.AIR_ACCEL
	
	air_accelerate(wish_dir, wish_speed, accel, delta)

	#if player move left/right but didn not move mouse,it will not accel
	if (global_rotation.y != last_frame_rotation):
		accelerate(wish_dir, wish_speed, accel, delta)
		last_frame_rotation = global_rotation.y
	 
	vel.y -= _data.gravity * _data.gravity_precent * delta
	air_accel_switch =false

func air_accelerate(wish_dir : Vector3, wish_speed : float, accel : float, delta):     #air accel
	var addspeed : float
	var accelspeed : float
	var _currentspeed : float
	var wishspd = wish_speed
	
	#clamp it to a resonable value
	if (_data.clamp_air_speed == true):
		wishspd = clamp((wishspd / _data.AIR_CAP - _data.AIR_CAP * _data.AIR_CAP), _data.AIR_CAP, _data.AIR_MAX_SPEED)
	else :
		wishspd = clamp((wishspd / _data.AIR_CAP - _data.AIR_CAP * _data.AIR_CAP), _data.AIR_CAP, _data.AIR_MAX_SPEED*100)
	_currentspeed = vel.dot(wish_dir)
	addspeed = wishspd - _currentspeed
	
	if(addspeed <= 0):
		return Vector3.ZERO
		
	accelspeed = accel * wishspd * delta

	accelspeed = min(accelspeed,addspeed)
	air_accel_switch = true
	
	vel_x  = vel.x + (accelspeed * wish_dir.x * _data.air_accel_precent)
	vel.x += accelspeed * wish_dir.x * _data.air_accel_precent * 0.7
	vel.y += accelspeed * wish_dir.y * _data.air_accel_precent
	vel.z += accelspeed * wish_dir.z * _data.air_accel_precent

func accelerate(wish_dir : Vector3, wish_speed : float, accel : float, delta) -> void:
	var addspeed : float
	var accelspeed : float
	var _currentspeed : float

	_currentspeed = vel.dot(wish_dir)
	addspeed = wish_speed - _currentspeed
	if(addspeed <= 0):
		return
	accelspeed = accel * delta * wish_speed
	if(accelspeed > addspeed):
		accelspeed = addspeed
	
	#little boost
	if (velocity.length() > 30): #in game 90 ups
		_data.accel_precent = .8
	else : 
		_data.accel_precent = .75

	if (!air_accel_switch):
		vel += accelspeed * wish_dir * _data.accel_precent
	else :
		vel.x = vel_x
		vel += accelspeed * wish_dir * .5
	
func handel_friction(t : float, delta) -> void:
	var vec : Vector3 = vel
	vec.y = 0
	var speed : float = vec.length()
	var drop :float = 0

	if (is_on_crouching or is_crouching):
		_friction = _data.CROUCH_FRICTION
	else :
		_friction = _data.STAND_FRICTION
	
	if(is_on_floor()):
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
		
	player_friction = newspeed #debug
	vel *= newspeed

func handel_jump() -> void:
	if (Input.is_action_just_pressed("jump") && is_on_floor()):
		_wishJump = true

	# if auto bunny is on , hold jump button will always jumpping ,unless released button
	if (_data.auto_bunny and Input.is_action_pressed("jump")):
		if (_wishJump == true):
			return
		else :
			_wishJump = true
	elif (_data.auto_bunny and Input.is_action_just_released("jump")):
		_wishJump = false

func handel_crouch(delta) -> void:
	collider = collider_shape.shape		#Player collider
	collide = ceilingcast.is_colliding()	#Initialize
	if (Input.is_action_pressed("crouch") or is_on_crouching):
		t1 += delta * 15	#smooth the position
		collider.height = _data.CROUCH_HEIGHT		#control colldier height
		head.position.y = lerp(head.position.y,_data.CAMERA_HEIGHT,t1)	#control camera height
		is_on_crouching = true
		if(head.position.y >= _data.CAMERA_HEIGHT):
			if(head.position.y - _data.CAMERA_HEIGHT <= 0.01):
				head.position.y = _data.CAMERA_HEIGHT
			t1 = 0	#reset
			is_crouching = true
			is_on_crouching = false
	# handel standing	
	# if last frame is collide something, it will not stand up
	if (is_crouching):	
		if (collide) :
			is_collide = true
		else :
			is_collide = false
		if (is_collide):
			is_last_frame_collide = is_collide
			return
		elif (!is_collide) :
			if(Input.is_action_just_released("crouch") or is_on_stand):
				#position.y += 0.55		#if you want a goldscr style jumping, ctrl+/ this line
				t2 += delta * 5		#smooth the position
				head.position.y = lerp(head.position.y,_data.stand_height,t2)		#control camera height
				collider.height = _data.stand_height		#control colldier height
				is_on_stand = true
				is_last_frame_collide = is_collide
				if (head.position.y >= _data.stand_height):
					t2 = 0		#reset
					is_on_stand = false
					is_crouching =false
					is_last_frame_collide = is_collide
			elif (is_last_frame_collide == true and Input.is_action_pressed("crouch")): 
				return
			elif (is_last_frame_collide == true and !Input.is_action_pressed("crouch")): #just copy and paste
				#position.y += 0.55		#if you want a goldscr style jumping, ctrl+/ this line
				t2 += delta * 5		#smooth the position
				head.position.y = lerp(head.position.y,_data.stand_height,t2)		#control camera height
				collider.height = _data.stand_height		#control colldier height
				is_on_stand = true
				is_last_frame_collide = is_collide

func speed_changer() -> void:
	if (Input.is_action_pressed("dash") and !is_crouching):
		currentspeed = _data.DASH_SPEED
	elif (is_crouching or is_on_crouching):
		currentspeed = _data.CROUCH_SPEED
	else :
		currentspeed = _data.WALK_SPEED

func current_speed_function():
	pos = velocity.x * velocity.x + velocity.z * velocity.z
		
func DEBUG_FUNTION():
	#default button "R"
	if(Input.is_action_just_pressed("test_reset")):
		position = DEBUG_origin_transform
		vel = Vector3.ZERO
		appliedVelocity = Vector3.ZERO
		topspeed = 0
	
	current_speed_function()
	#signal to hud
	DEBUGING_.emit("global_position: " +var_to_str(global_position) + "\n" \
	+ "vel: " + var_to_str(vel) + "\n" \
	+ "dir: " + var_to_str(dir) + "\n" \
	+ "velocity: " + var_to_str(velocity) + "\n" \
	+ "ground: " + var_to_str(is_on_floor()) + "\n" \
	+ "wish jump: " + var_to_str(_wishJump) + "\n" \
	+ "is_crouching: " + var_to_str(is_crouching) + "\n" \
	+ "collide: " + var_to_str(is_collide) + "\n" \
	+ "last frame collide: " + var_to_str(is_last_frame_collide) + "\n" \
	+ var_to_str(raw_input) + "\n" \
	+ "FRICTION " + var_to_str(player_friction) + "\n" \
	+ "topspeed: " + var_to_str(topspeed) + "\n" \
 	+ "speed " + var_to_str(pos) )	
	
