# Ported from https://github.com/WiggleWizard/quake3-movement-unity3d/blob/master/CPMPlayer.cs
#Ref:
#https://github.com/AkimBowX2/Godot-4_FPS_controller/blob/main/scenes/player/player.gd
#https://github.com/WiggleWizard/quake3-movement-unity3d/blob/master/CPMPlayer.cs
#https://github.com/dwlcj/Godot-Strafe-Jumping/blob/main/Scenes/Player.gd#L161
#https://www.youtube.com/watch?v=v3zT3Z5apaM&t=165s
#https://adrianb.io/2015/02/14/bunnyhop.html
#https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c#L235

extends CharacterBody3D

@export_subgroup("speed")
@export var AIR_ADD_SPEED :float = 4
@export var WALK_SPEED :float = 6
@export var DASH_SPEED :float = 15
@export var JUMP_FORCE :float = 10
var CROUCH_SPEED :float = 5

@export_subgroup("crouch")
@export var CROUCH_MAX_SPEED :float = 3
@export var CROUCH_AIR_ADD_SPEED : float = 4
@export var CROUCH_HEIGHT : float = .8			#crouch height
@export var CAMERA_HEIGHT :float = 1.2			#crouch camera height
var stand_height : float = 1.5

@export_subgroup("accelration")
@export var RUN_ACCEL :float = 14
@export var RUN_DECEEL :float = 10
@export var STARFE_SPEED :float = 2
@export var AIR_ACCEL :float = 2
@export var AIR_DECCEL :float = 2
@export var AIR_CONTROL :float = 0
@export var FRICTION :float = 6

@export_subgroup("sensitrivity")
@export var MOUSE_SENSITRIVITY = 2

#DEBUG
@export_subgroup("DEBUG")
@export var gravity = 34
#region debug
@onready var collider_shape :CollisionShape3D = $Collider		#collider
@onready var collider : CapsuleShape3D							#collider shape
@onready var ceilingcast :RayCast3D = $Root/CeilingCast			#fornt raycast
@onready var ceilingcast2 :RayCast3D = $Root/CeilingCast2		#back raycast
@onready var head = $Root

var _air_controlAdditionForward :float = 32
var topspeed :float = 0
var currentspeed : float
var player_friction :float = 0

var vel : Vector3 = Vector3.ZERO
var appliedVelocity : Vector3
var DEBUG_origin_transform :Vector3
var DEBUG_wishdir :Vector3

var _wishJump : bool = false 
var _jumpQueue : bool = false 
var is_falling : bool = false 
var is_crouching : bool = false 
var is_on_crouching : bool = false 
var is_on_stand : bool = false 
var mouse : bool = false 
var is_last_frame_collide :bool = false
var is_collide :bool = false
var collide :bool = false

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
	
	appliedVelocity = velocity.lerp(vel, delta * 10)
	velocity = appliedVelocity
	move_and_slide()
	
	handel_jump()
	handel_crouch(delta)
	var udp :Vector3 = vel
	udp.y = 0
	if(udp.length() > topspeed):
		topspeed = udp.length()
	
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
	accelerate(wish_dir, wish_speed, RUN_ACCEL, delta)
	
	#fix werid gravity problem, reset velocity.y
	if (is_on_floor()):
		vel.y = 0

	if (_wishJump):
		vel.y = JUMP_FORCE
		_wishJump = false
	
func air_move(delta) -> void:
	# no more starfing on ceiling
	if (is_on_ceiling()):
		var jumpvel = vel.y
		vel.y = jumpvel
		vel.y -= gravity * delta * 5		
	var wish_dir : Vector3	
	var _wishvel : float= AIR_ACCEL
	var accel : float
	wish_dir = Vector3(dir.x, 0, dir.z)
	DEBUG_wishdir = wish_dir	
	var wish_speed :float = wish_dir.length()
	var add_speed :float 
	if(is_crouching):
		add_speed = CROUCH_AIR_ADD_SPEED
	else :
		add_speed = AIR_ADD_SPEED
	wish_speed *= add_speed
	wish_dir = wish_dir.normalized()
	var wish_speed2 : float = wish_speed
	if(vel.dot(wish_dir) < 0.0):
		accel = AIR_DECCEL
	else :
		accel = AIR_ACCEL
	#left or right move to accelerate	
	if (dir.z == 0.0 and dir.x != 0.0):
		if (wish_speed > STARFE_SPEED):
			wish_speed = STARFE_SPEED
		accel = AIR_ACCEL
	
	accelerate(wish_dir, wish_speed, accel, delta)
	if (AIR_CONTROL > 0):
		air_control(wish_dir, wish_speed2, delta)	
	 
	vel.y -= gravity * delta
		
func air_control(wish_dir : Vector3, wish_speed : float, delta) -> void:
	if(abs(raw_input.y) < 0.1 or abs(wish_speed) < 0.1 ):
		return
	#speed too slow can't not accelerate
	if(vel.dot(wish_dir) <= 0.2):
		return
	var zspeed: float= vel.y
	vel.y = 0
	var speed: float = vel.length()
	vel = vel.normalized()
	var dot: float= vel.dot(wish_dir)
	var k: float = _air_controlAdditionForward
	k *= AIR_CONTROL * dot * dot * delta
	
	if (dot > 0):
		vel.x = vel.x *speed + wish_dir.x * k
		vel.y = vel.y *speed + wish_dir.y * k
		vel.z = vel.z *speed + wish_dir.z * k
		vel = vel.normalized()
	vel.x *= speed
	vel.y  = zspeed # Notice this line
	vel.z *= speed

func accelerate(wish_dir : Vector3, wish_speed : float, accel : float, delta) -> void:
	var addspeed : float
	var accelspeed : float
	var _currentspeed : float
	# control crouch max speed
	# if crouch speed lower than 5, it will not accelerate, so i just clamp it
	if(is_crouching):
		if (velocity.length() > CROUCH_MAX_SPEED and is_on_floor()):
			return
		if(!is_on_floor() and velocity.length() > CROUCH_AIR_ADD_SPEED):
			return

	_currentspeed = vel.dot(wish_dir)
	addspeed = wish_speed - _currentspeed
	if(addspeed <= 0):
		return
	accelspeed = accel * delta * wish_speed
	if(accelspeed > addspeed):
		accelspeed = addspeed
	
	vel.x += accelspeed * wish_dir.x
	vel.z += accelspeed * wish_dir.z
	
func handel_friction(t : float, delta) -> void:
	var vec : Vector3 = vel
	vec.y = 0
	var speed : float = vec.length()
	var drop :float = 0
	
	if(is_on_floor()):
		var control :float 
		if (speed < RUN_DECEEL):
			control = RUN_DECEEL
		else :
			control = speed
		drop = control * FRICTION * delta * t
		
	var newspeed : float = speed - drop
	
	if (newspeed < 0) :
		newspeed = 0
	if (speed > 0) : 
		newspeed /= speed
		
	player_friction = newspeed #debug
	vel.x *= newspeed
	vel.z *= newspeed

func handel_jump() -> void:
	if (Input.is_action_just_pressed("jump") && is_on_floor()):
		_wishJump = true
	if (!is_on_floor() and Input.is_action_just_pressed("jump")):
		_jumpQueue = true	
	if (is_on_floor() && _jumpQueue):
		_wishJump = true
		_jumpQueue = false

func handel_crouch(delta) -> void:
	collider = collider_shape.shape		#Player collider
	collide = ceilingcast.is_colliding()	#Initialize
	if (Input.is_action_pressed("crouch") or is_on_crouching):
		t1 += delta * 15	#smooth the position
		head.position.y = lerp(head.position.y,CAMERA_HEIGHT,t1)	#control camera height
		collider.height = CROUCH_HEIGHT		#control colldier height
		is_on_crouching = true
		if(head.position.y >= CAMERA_HEIGHT):
			if(head.position.y - CAMERA_HEIGHT <= 0.02):
				head.position.y = CAMERA_HEIGHT
			t1 = 0	#reset
			is_crouching = true
			is_on_crouching = false
	# handel standing	
	# if last frame is collide something, it will not stand up
	if (is_crouching):	
		handel_collider()
		if (is_collide):
			is_last_frame_collide = is_collide
			return
		elif (!is_collide) :
			if(Input.is_action_just_released("crouch") or is_on_stand):
				#position.y += 0.55		#if you want a goldscr style jumping, ctrl+/ this line
				t2 += delta * 5		#smooth the position
				head.position.y = lerp(head.position.y,stand_height,t2)		#control camera height
				collider.height = stand_height		#control colldier height
				is_on_stand = true
				is_last_frame_collide = is_collide
				if (head.position.y >= stand_height):
					t2 = 0		#reset
					is_on_stand = false
					is_crouching =false
					is_last_frame_collide = is_collide
			elif (is_last_frame_collide == true and Input.is_action_pressed("crouch")): 
				return
			elif (is_last_frame_collide == true and !Input.is_action_pressed("crouch")):
				#just copy and paste
				#position.y += 0.55		#if you want a goldscr style jumping, ctrl+/ this line
				t2 += delta * 5		#smooth the position
				head.position.y = lerp(head.position.y,stand_height,t2)		#control camera height
				collider.height = stand_height		#control colldier height
				is_on_stand = true
				is_last_frame_collide = is_collide

#is it touching ceiling
func handel_collider():
	if (ceilingcast.is_colliding()):
		is_collide = true
	elif (!ceilingcast.is_colliding()):
		if(ceilingcast2.is_colliding()):
			is_collide = true
		else:
			is_collide = false
				
func speed_changer() -> void:
	if (Input.is_action_pressed("dash") and !is_crouching):
		currentspeed = DASH_SPEED
	elif (is_crouching):
		currentspeed = CROUCH_SPEED
	else :
		currentspeed = WALK_SPEED
		
func DEBUG_FUNTION():
	#default button "R"
	if(Input.is_action_just_pressed("test_reset")):
		position = DEBUG_origin_transform
		vel = Vector3.ZERO
		appliedVelocity = Vector3.ZERO
		
	#signal to hud
	DEBUGING_.emit(var_to_str(global_position) + "\n" \
	+ var_to_str(vel) + "\n" \
	+ var_to_str(dir) + "\n" \
	+ "ground: " + var_to_str(is_on_floor()) + "\n" \
	+ "is_crouching: " + var_to_str(is_crouching) + "\n" \
	+ "collide: " + var_to_str(is_collide) + "\n" \
	+ "last frame collide: " + var_to_str(is_last_frame_collide) + "\n" \
	+ var_to_str(raw_input) + "\n" \
	+ "FRICTION " + var_to_str(player_friction) + "\n" \
	+ "topspeed: " + var_to_str(topspeed) + "\n" \
	+ "speed " + var_to_str(velocity.length()) )	
	
