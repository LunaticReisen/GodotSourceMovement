@tool
class_name FuncLadder
extends Area3D

func _init():
    self.add_to_group("AREA_LADDER",true)
    connect("body_entered" , _on_ent_entered)
    connect("body_exited" , _on_ent_exited)
    var top_ladder = Marker3D.new()
    add_child(top_ladder)
    top_ladder.add_to_group("MARKER_LADDERTOP")
    top_ladder.position.y = self.position.y * 2

func _on_ent_entered(ent: Node) -> void:
    print("connect")

func _on_ent_exited(ent: Node) -> void:
    print("disconnect")
