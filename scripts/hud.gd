extends Control

func _ready():
	$PauseMenu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	#"F3" can let the debug text hide
	if (event.is_action_pressed("test_text")):
		if ($DEBUG_TEXT.visible == true):
			$DEBUG_TEXT.hide()
			# print("disabled!")
		elif ($DEBUG_TEXT.visible == false):
			$DEBUG_TEXT.visible = true
			# print("enabled!")
	#"ESC" can let the mouse free
	if(event.is_action_pressed("pause_menu")):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$PauseMenu.visible = true
		elif (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$PauseMenu.hide()

func _on_player_debuging_(pos):
	$DEBUG_TEXT.text = str(pos)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_countine_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$PauseMenu.hide()
