@tool
class_name FuncWater
extends Area3D

func _init():
    monitorable = false
    self.add_to_group("AREA_WATER",true)
    connect("body_entered" , _on_ent_entered)

func _on_ent_entered(ent: Node) -> void:
    print(ent)
    print("fuck it")

