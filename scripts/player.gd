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
@export var AIR_ADD_SPEED :float = 5
@export var WALK_SPEED :float = 10
@export var DASH_SPEED :float = 15
@export var MAX_SPEED :float = 20
@export var JUMP_FORCE :float = 10

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
#TODO: CONTROLLER SUPPORT
var CONTORLLER_SENSITRIVITY = 700

#DEBUG
@export_subgroup("DEBUG")
@export var _air_controlAdditionForward :float = 32
@export var gravity = 30
var vel : Vector3 = Vector3.ZERO
var TOP_SPEED :float = 0
var currentspeed : float
var player_friction :float = 0
var _wishJump : bool = false 
var _jumpQueue : bool = false 
var appliedVelocity : Vector3
var DEBUG_origin_transform :Vector3
var raw_input
var DEBUG_wishdir :Vector3
var dir

signal DEBUGING_

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DEBUG_origin_transform = global_position
func _physics_process(delta):
	DEBUG_FUNTION()
	speed_changer()
	process_movement(delta)
	
	appliedVelocity = velocity.lerp(vel, delta * 10)
	velocity = appliedVelocity
	move_and_slide()
	
	handel_jump()
	var udp :Vector3 = vel
	udp.y = 0
	if(udp.length() > TOP_SPEED):
		TOP_SPEED = udp.length()
	
func process_movement(delta) -> void:
	raw_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	dir = (transform.basis * Vector3(raw_input.x, 0 , raw_input.y)).normalized()
	if (is_on_floor()):
		ground_move(delta)
	else :
		air_move(delta)

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
	
	if (_wishJump):
		vel.y = JUMP_FORCE
		_wishJump = false
			
func air_move(delta) -> void:
	var wish_dir : Vector3	
	var _wishvel : float= AIR_ACCEL
	var accel : float
	wish_dir = Vector3(dir.x, 0, dir.z)
	DEBUG_wishdir = wish_dir	
	var wish_speed :float = wish_dir.length()
	wish_speed *= AIR_ADD_SPEED
	wish_dir = wish_dir.normalized()
	var wish_speed2 : float = wish_speed
	if(vel.dot(wish_dir) < 0.0):
		accel = AIR_DECCEL
	else :
		accel = AIR_ACCEL
	#forward&backward to accelerate	
	if (dir.z == 0.0 and dir.x != 0.0):
		if (wish_speed > STARFE_SPEED):
			wish_speed = STARFE_SPEED
		accel = AIR_ACCEL
	
	accelerate(wish_dir, wish_speed, accel, delta)
	if (AIR_CONTROL > 0):
		air_control(wish_dir, wish_speed2, delta)	
	
	vel.y -= gravity * delta
		
func air_control(wish_dir : Vector3, wish_speed : float, delta) -> void:
	if(abs(dir.z) < 0.1 or abs(wish_speed) < 0.1 ):
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
	vel.y  = zspeed # Note this line
	vel.z *= speed

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
	player_friction = newspeed 
	
	if (newspeed < 0) :
		newspeed = 0
	if (speed > 0) : 
		newspeed /= speed
		
	vel.x *= newspeed
	vel.z *= newspeed

func handel_jump() -> void:
	if (Input.is_action_just_pressed("jump") && is_on_floor()):
		_wishJump = true
	if (!is_on_floor() && Input.is_action_just_pressed("jump")):
		_jumpQueue = true	
	if (is_on_floor() && _jumpQueue):
		_wishJump = true
		_jumpQueue = false

func speed_changer() -> void:
	if (Input.is_action_pressed("dash")):
		currentspeed = DASH_SPEED
	elif (Input.is_action_pressed("crouch")):
		currentspeed = WALK_SPEED * .5
	else :
		currentspeed = WALK_SPEED
		
func DEBUG_FUNTION():
	#default button "esc" & "left mouse"
	if(Input.is_action_pressed("pause_menu")):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
	if(Input.is_action_pressed("fire")):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	#default button "R"
	if(Input.is_action_just_pressed("test_reset")):
		position = DEBUG_origin_transform
		vel = Vector3.ZERO
		appliedVelocity = Vector3.ZERO
		
	#signal to hud
	DEBUGING_.emit(var_to_str(global_position) + "\n" \
	+ "ground: " + var_to_str(is_on_floor()) + "\n" \
	+ var_to_str(raw_input) + "\n" \
	+ "FRICTION " + var_to_str(player_friction) + "\n" \
	+ "speed " + var_to_str(velocity.length()) )	
