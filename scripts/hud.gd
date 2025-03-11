extends Control

func _ready():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$bg/bg2/switches/stepswitch.button_pressed = Global.player_data.step_switch
	$bg/bg2/switches/accelswitch.button_pressed = Global.player_data.accel_switch
	$bg/bg2/switches/bunnyswitch.button_pressed = Global.player_data.auto_bunny
	$bg/bg2/switches/surfswitch.button_pressed = false
	$bg/bg2/switches/ladderswitch.button_pressed = Global.player_data.ladder_boosting
	$bg/bg2/line_edits/surf_ang.set_placeholder(var_to_str(Global.player_data.SLOPE_LIMIT))

func _input(event):
	#"ESC" can let the mouse free	
	if(event.is_action_pressed("pause_menu")):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
			show()
		elif (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			hide()
			get_tree().paused = false
	
	if(event.is_action_pressed("test_text")):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_countine_button_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()

func _on_settings_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_bunnyswitch_toggled(toggled_on:bool) -> void:
	Global.player_data.auto_bunny = toggled_on

func _on_stepswitch_toggled(toggled_on:bool) -> void:
	Global.player_data.step_switch = toggled_on

func _on_accelswitch_toggled(toggled_on:bool) -> void:
	Global.player_data.accel_switch = toggled_on

func _on_step_ang_text_submitted(new_text:String) -> void:
	Global.player_data.camera_smooth_amount = float(new_text)

func _on_surf_ang_text_submitted(new_text:String) -> void:
	Global.player_data.SLOPE_LIMIT = float(new_text)

func _on_ladderswitch_toggled(toggled_on:bool) -> void:
	Global.player_data.ladder_boosting = toggled_on

func _on_surfswitch_toggled(toggled_on:bool) -> void:
	if toggled_on:
		Global.player_data.AIR_CAP = Global.player_data.SURF_AIR_CAP
	else :
		Global.player_data.AIR_CAP = Global.player_data.GROUND_AIR_CAP
