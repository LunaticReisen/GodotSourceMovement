@tool
class_name FuncLadder
extends Area3D

@export var direction : int
@export var angle : float

func _func_godot_apply_properties(props: Dictionary) -> void:
    direction = props["direction"] as int
    angle = props["angle"] as float

func _init():
    self.add_to_group("AREA_LADDER",true)
    connect("body_entered" , _on_ent_entered)
    connect("body_exited" , _on_ent_exited)
    # self.rotation_degrees.y = angle
    var top_ladder = Marker3D.new()
    add_child(top_ladder)
    top_ladder.add_to_group("MARKER_LADDERTOP")
    top_ladder.position.y = self.position.y

func _ready():
    init_object()
    pass

func init_object():
    if direction == 0 or direction == 1:
        for child in self.get_children():
            if child is CollisionShape3D:
                print(child.rotation_degrees.y)
                self.rotation_degrees.y = 90
                child.rotation_degrees.y = -90
                print("yes？")
                print(child.rotation_degrees.y)

func _on_ent_entered(ent: Node) -> void:
    print("LADDER:climb")

func _on_ent_exited(ent: Node) -> void:
    print("LADDER:exit")

#TODO:
#能在tb设置梯子的方向
#把shape3D中的Array提取出来，通过梯子方向与比较x和y的大小确定要偏移的方向
#self.position.x/y += xx; self.get_child(0).position.x/y += xx