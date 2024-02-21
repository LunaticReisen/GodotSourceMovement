extends CanvasLayer

func _on_player_debuging_(pos):
	$TEXT.text = str(pos)
