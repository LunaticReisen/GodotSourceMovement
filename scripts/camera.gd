extends Node3D

@export var mouseSensitrivity = 2.0
@onready var root_character : CharacterBody3D = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if(Input.is_action_just_pressed("test_reset")):
	#position = Vector3.ZERO	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		root_character.rotate_y(deg_to_rad(event.relative.x * mouseSensitrivity * 0.1 * -1))
		rotate_x(deg_to_rad(event.relative.y * mouseSensitrivity * 0.1 * -1))
		rotation.x = clamp(rotation.x, -1.3, 1.3)
