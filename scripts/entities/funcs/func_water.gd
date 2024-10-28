@tool
class_name FuncWater
extends Area3D

func _init():
    add_to_group("water")
    connect("body_entered" , _on_ent_entered)

func _on_ent_entered():
    print("fuck it")
