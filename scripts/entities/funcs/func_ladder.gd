@tool
class_name FuncLadder
extends Area3D

@export var angle : float

func _func_godot_apply_properties(props: Dictionary) -> void:
    angle = props["angle"] as float

func _init():
    self.add_to_group("AREA_LADDER",true)
    connect("body_entered" , _on_ent_entered)
    connect("body_exited" , _on_ent_exited)
    init_object()
    var top_ladder = Marker3D.new()
    add_child(top_ladder)
    top_ladder.add_to_group("MARKER_LADDERTOP")
    top_ladder.position.y = self.position.y

func init_object():
    self.rotate_y(angle)
    # var collisionShape
    # if self.get_child(1) is CollisionShape3D :
    #     collisionShape = self.get_child(1)
    for child in get_children():
        if child is CollisionShape3D:
            child.rotate_y(-angle)
            print("yes？")

func _on_ent_entered(ent: Node) -> void:
    print("LADDER:climb")

func _on_ent_exited(ent: Node) -> void:
    print("LADDER:exit")

#TODO:
#能在tb设置梯子的方向
#把shape3D中的Array提取出来，通过梯子方向与比较x和y的大小确定要偏移的方向
#self.position.x/y += xx; self.get_child(0).position.x/y += xx