extends Node

class_name Grab_Fuction

@onready var hand :Marker3D = $"../Root/Head/Hand/marker3d"
@onready var interaction :RayCast3D = $"../Root/Head/Hand/Interaction"
@onready var joint :Generic6DOFJoint3D = $"../Root/Head/Hand/Joint"
@onready var staticbody :StaticBody3D = $"../Root/Head/Hand/GrabStaticBody"
@onready var _data :Resource = Global.player._data

var picked_object
var hand_original_position

func _ready():
	hand_original_position = hand.position

func _input(event):

	if event.is_action_pressed("use"):
		if picked_object == null :
			pick_object()
		else :
			dropping_object()
			hand.position = hand_original_position


	if event.is_action_pressed("fire"):
		if picked_object != null :
			throwing_object()
			hand.position = hand_original_position

	if event.is_action_pressed("fire_second"): 
		if picked_object != null :
			dropping_object()
			hand.position = hand_original_position

	if Input.is_action_pressed("reload"):
		_data.view_lock = true
		rotating_object(event)
		# distance_object()

	if Input.is_action_just_released("reload"):
		_data.view_lock = false
	
	if _data.grab_power:
		distance_object()

func _physics_process(delta):	
	if picked_object != null :
		var hand_position = hand.global_transform.origin
		var picked_obj_position = picked_object.global_transform.origin
		picked_object.linear_velocity = (hand_position - picked_obj_position) * _data.grab_power

func pick_object():
	var collider
	if interaction.is_colliding():
		collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider
		joint.node_b = picked_object.get_path()
		_data.grab_up = true

func dropping_object():
	if picked_object != null :
		picked_object = null
		joint.node_b = NodePath("")
		_data.grab_up = false

func throwing_object():
	if picked_object != null :
		var knockback = picked_object.global_position - Global.player.global_position
		picked_object.apply_central_impulse(knockback * _data.throw_power)
		dropping_object()
	
func rotating_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			staticbody.rotate_x(deg_to_rad(event.relative.y * _data.rotation_power))
			staticbody.rotate_y(deg_to_rad(event.relative.x * _data.rotation_power))

func distance_object():
	if picked_object != null:
		if Input.is_action_pressed("mouse_wheel_up"):
			hand.position.z -= 1 * _data.distance_power
		if Input.is_action_pressed("mouse_wheel_down"):
			hand.position.z += 1 * _data.distance_power
