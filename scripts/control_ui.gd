extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	%debug_view_up.modulate.a = lerp(%debug_view_up.modulate.a,float(Input.is_action_pressed("move_forward")),delta*25)
	%debug_view_down.modulate.a = lerp(%debug_view_down.modulate.a,float(Input.is_action_pressed("move_back")),delta*25)
	%debug_view_left.modulate.a = lerp(%debug_view_left.modulate.a,float(Input.is_action_pressed("move_left")),delta*25)
	%debug_view_right.modulate.a = lerp(%debug_view_right.modulate.a,float(Input.is_action_pressed("move_right")),delta*25)
	%debug_view_jump.modulate.a = lerp(%debug_view_jump.modulate.a,float(Input.is_action_pressed("jump")),delta*25)
	%debug_view_dash.modulate.a = lerp(%debug_view_dash.modulate.a,float(Input.is_action_pressed("dash")),delta*25)
	%debug_view_crouch.modulate.a = lerp(%debug_view_crouch.modulate.a,float(Input.is_action_pressed("crouch")),delta*25)
	%debug_view_use.modulate.a = lerp(%debug_view_use.modulate.a,float(Input.is_action_pressed("use")),delta*25)
