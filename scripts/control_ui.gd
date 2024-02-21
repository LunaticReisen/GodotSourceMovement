extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	$up.modulate.a = lerp($up.modulate.a,float(Input.is_action_pressed("move_forward")),delta*25)
	$down.modulate.a = lerp($down.modulate.a,float(Input.is_action_pressed("move_back")),delta*25)
	$left.modulate.a = lerp($left.modulate.a,float(Input.is_action_pressed("move_left")),delta*25)
	$right.modulate.a = lerp($right.modulate.a,float(Input.is_action_pressed("move_right")),delta*25)
	$space.modulate.a = lerp($space.modulate.a,float(Input.is_action_pressed("jump")),delta*25)
	$dash.modulate.a = lerp($dash.modulate.a,float(Input.is_action_pressed("dash")),delta*25)
