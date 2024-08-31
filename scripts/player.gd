extends CharacterBody3D

#region debug
@export var _data :Resource
@onready var collider :CollisionShape3D = $PlayerCollider		#collider
@onready var collider_shape 									#collider shape
@onready var ceilingcast :ShapeCast3D = $Root/CeilingCast		#raycast
@onready var player_physic : Player_Physic = $Player_Physic		#player_physic
@onready var head = $Root

var pos : Vector3
var topspeed :float = 0
var _wishspeed :float = 0
var currentspeed : float = 0
var player_friction :float = 0
var checker_movement = "what"

var vel : Vector3 = Vector3.ZERO
var DEBUG_origin_transform :Vector3
var DEBUG_wishdir :Vector3

var _wishJump : bool = false 

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

#crouch timer
var t1 : float
var t2 : float
#endregion

#hud signal
signal DEBUGING_

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DEBUG_origin_transform = global_position
	_data.on_floor = false
	Global.player = self
	
func _input(event):	
	if(Input.is_action_just_pressed("test_reset")):
		get_tree().reload_current_scene()


func _physics_process(delta):
	debug_var()
	speed_changer()
	process_movement(delta)

	#Let the magic come true
	velocity = vel
	is_it_collide =move_and_slide_own()
	vel = velocity

	crouching = handel_crouch(delta)
	handel_jump()
	print(ceilingcast.is_colliding())
	#top speed calculation
	if (get_current_speed() > topspeed):
		topspeed = get_current_speed()
	
func process_movement(delta) -> void:
	raw_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")	#Initialize
	dir = player_physic.get_movement_axis()
	if (_data.on_floor):
		ground_move(delta)
		checker_movement = "ground"
	else :
		air_move(delta)
		checker_movement = "air"

#See more in https://github.com/WiggleWizard/quake3-movement-unity3d/blob/master/CPMPlayer.cs
func ground_move(delta) -> void:
	_data.on_floor = true
	var accle : float
	if (!_wishJump):
		vel = player_physic.handel_friction(vel,1,crouching,delta)
	else :
		vel = player_physic.handel_friction(vel,0,crouching,delta)		
	var wish_dir : Vector3 = Vector3(dir.x, 0, dir.z)
	DEBUG_wishdir = wish_dir
	wish_dir = wish_dir.normalized()
	var wish_speed : float = wish_dir.length()
	wish_speed *= currentspeed
	if (crouching):
		accle = _data.CROUCH_ACCEL
	else :
		accle = _data.RUN_ACCEL 

	vel = player_physic.accelerate(vel, wish_dir, wish_speed, accle, crouching, delta)

	if (_wishJump):
		vel.y = _data.JUMP_FORCE
		_wishJump = false

	_wishspeed = wish_speed


func air_move(delta) -> void:
	var accel : float
	var add_speed :float 
	var _wishvel : float= _data.AIR_ACCEL
	var wish_dir : Vector3	 = Vector3(dir.x, 0, dir.z).normalized()
	var wish_speed :float = wish_dir.length()
	DEBUG_wishdir = wish_dir

	if(is_crouching):
		add_speed = _data.CROUCH_AIR_ADD_SPEED
	else :
		add_speed = _data.AIR_ADD_SPEED
	wish_speed *= add_speed

	#left or right move to accelerate	
	if (raw_input.y < 0.1 and abs(dir.x) > 0.0):
		if (wish_speed > _data.AIR_MAX_SPEED):
			wish_speed =_data.AIR_MAX_SPEED
		if (crouching):
			accel = _data.CROUCH_AIR_ACCEL
		else :
			accel = _data.AIR_ACCEL
	
	#clamp the max speed
	if wish_speed != 0.0 and wish_speed > _data.AIR_MAX_SPEED:
		wish_speed = _data.AIR_MAX_SPEED
	
	vel = player_physic.air_accelerate(vel,wish_dir, wish_speed, accel, delta)
	
	vel.y -= _data.gravity * delta * _data.gravity_precent

	_wishspeed = wish_speed #debug


func handel_jump() -> void:
	if (Input.is_action_just_pressed("jump") && _data.on_floor):
		_wishJump = true

	# if auto bunny is on ,hold jump button will always jumpping ,unless released button
	if (_data.auto_bunny and Input.is_action_pressed("jump")):
		if (_wishJump == true):
			return
		else :
			_wishJump = true
	elif (_data.auto_bunny and Input.is_action_just_released("jump")):
		_wishJump = false

func handel_crouch(delta) -> bool:
	collider_shape = collider.shape		#Player collider shape
	collide = ceilingcast.is_colliding()	#Initialize
	if (Input.is_action_pressed("crouch") or is_on_crouching):
		t1 += delta * 15	#smooth the position
		collider_shape.height = _data.CROUCH_HEIGHT		#control colldier height
		if (!collide):
			head.position.y = lerp(head.position.y,_data.CAMERA_HEIGHT,t1)	#control camera height
		is_on_crouching = true
		if(head.position.y >= _data.CAMERA_HEIGHT):
			if(head.position.y - _data.CAMERA_HEIGHT <= 0.01):
				head.position.y = _data.CAMERA_HEIGHT
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
				head.position.y = lerp(head.position.y,_data.stand_height,t2)		#control camera height
				collider_shape.height = _data.stand_height		#control colldier height
				is_on_stand = true
				is_last_frame_collide = is_collide
				if (head.position.y >= _data.stand_height) :
					t2 = 0		#reset
					is_on_stand = false
					is_crouching =false
					is_last_frame_collide = is_collide
			elif (is_last_frame_collide == true and Input.is_action_pressed("crouch")) : 
				return true
			elif (is_last_frame_collide == true and !Input.is_action_pressed("crouch")) : #just copy and paste
				#position.y += 0.55		#if you want a goldscr style jumping, ctrl+/ this line
				t2 += delta * 5		#smooth the position
				head.position.y = lerp(head.position.y,_data.stand_height,t2)		#control camera height
				collider_shape.height = _data.stand_height		#control colldier height
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
	_data.on_floor = false

	#check floor
	var checkMotion := velocity * (1/60.)
	checkMotion.y  -= _data.gravity * (1/360.)
		
	var testcol := move_and_collide(checkMotion, true)
	# print(testcol)
	if testcol:
		var testNormal = testcol.get_normal()
		if (testNormal.angle_to(up_direction) < _data.SLOPE_LIMIT):
			_data.on_floor = true

	# Loop performing the move
	var motion = velocity * get_delta_time()

	for step in max_slides:
		
		var collision := move_and_collide(motion)

		if move_and_collide(motion,true) :
			var test : KinematicCollision3D = move_and_collide(motion,true)
			if test.get_collider() is RigidBody3D :
				# print(test.get_collider())
				var _p : float = 1
				print(test.get_collider().mass)
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
		# print(velocity)
		
		motion = collision.get_remainder().slide(normal)
		velocity = velocity.slide(normal)
		# print(velocity)
		# Collision has occurred
		collided = true
	return collided

func speed_changer() -> void:
	if (Input.is_action_pressed("dash") and !is_crouching):
		currentspeed = _data.DASH_SPEED
	elif (is_crouching or is_on_crouching):
		currentspeed = _data.CROUCH_SPEED
	else :
		currentspeed = _data.WALK_SPEED

func get_current_speed():
	pos = velocity
	pos.y = 0
	return pos.length()

func debug_var():
	Global.debug_panel.add_property("velocity", velocity ,1)
	Global.debug_panel.add_property("raw_input", raw_input ,2)
	Global.debug_panel.add_property("position", global_position ,4)
	Global.debug_panel.add_property("topspeed", topspeed ,5)
	Global.debug_panel.add_property("speed", get_current_speed() ,6)

func get_delta_time():
	if Engine.is_in_physics_frame():
		return get_physics_process_delta_time()
	return get_process_delta_time()

#trigger the area3d will put you up
func _on_area_3d_body_entered(body:Node3D) -> void:
	position = DEBUG_origin_transform

func _on_check_button_toggled(toggled_on : bool) -> void:
	if toggled_on:
		_data.auto_bunny = true
	if !toggled_on:
		_data.auto_bunny = false
