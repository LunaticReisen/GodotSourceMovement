extends Control

func _ready():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_countine_button_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()

func _on_settings_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_bunnyswitch_toggled(toggled_on:bool) -> void:
	Global.player_data.auto_bunny = toggled_on
	pass # Replace with function body.
