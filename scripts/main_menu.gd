extends Control

func _on_map_1_pressed():
    get_tree().change_scene_to_file("res://maps/test_lab.tscn")
func _on_map_2_pressed():
    get_tree().change_scene_to_file("res://maps/test_intreaction.tscn")
func _on_map_3_pressed() -> void:
    get_tree().change_scene_to_file("res://maps/test_stairs.tscn")
func _on_quit_pressed():
    get_tree().quit()
