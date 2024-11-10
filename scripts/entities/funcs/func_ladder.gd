@tool
class_name FuncLadder
extends Area3D

# In Godot:
# x+ is NORTH , z+ is EAST

# In TrenchBroom:
# y+ is NORTH , x+ is EAST

@export var direction : int
@export var angle : float
@export var collision_size : Vector3

#more infos in https://github.com/func-godot/func_godot_example_basic
func _func_godot_apply_properties(props: Dictionary) -> void:
    direction = props["direction"] as int
    angle = props["angle"] as float

func _init():
    self.add_to_group("AREA_LADDER",true)

    #debug
    connect("body_entered" , _on_ent_entered)
    connect("body_exited" , _on_ent_exited)

    #add ladder marker
    var top_ladder = Marker3D.new()
    add_child(top_ladder)
    top_ladder.add_to_group("MARKER_LADDERTOP")
    top_ladder.position.y = self.position.y

func _ready():
    init_ladder_collision()
    init_ladder_position()
    
func init_ladder_collision():
    if direction == 0:
        for child in self.get_children():
            if child is CollisionShape3D:
                self.rotation_degrees.y = 90
                child.rotation_degrees.y = -90

    if direction == 1:
        for child in self.get_children():
            if child is CollisionShape3D:
                self.rotation_degrees.y = -90
                child.rotation_degrees.y = 90

    # if direction == 2:
    #     for child in self.get_children():
    #         if child is CollisionShape3D:
    #             self.rotation_degrees.y = 180
    #             child.rotation_degrees.y = 180

    if direction == 3 :
        for child in self.get_children():
            if child is CollisionShape3D:
                self.rotation_degrees.y = 180
                child.rotation_degrees.y = -180

    #Get collision size from ConvexPolygonShape
    for child in self.get_children():
        if child is CollisionShape3D:
            collision_size = abs(child.shape.get_points()[0])

func init_ladder_position():
    match direction:
        0 as int : #North
            self.global_position.x += collision_size.x
            for child in self.get_children():
                if child is CollisionShape3D:
                    child.global_position.x -= collision_size.x
                    # print("0")
            pass
        1 as int : #South
            self.global_position.x -= collision_size.x
            for child in self.get_children():
                if child is CollisionShape3D: 
                    child.global_position.x += collision_size.x
                    # print("1")
            pass
        2 as int : #East
            self.global_position.z += collision_size.z
            for child in self.get_children():
                if child is CollisionShape3D:
                    child.global_position.z -= collision_size.z
                    # print("2") 
            pass
        3 as int : #West
            self.global_position.z -= collision_size.z
            for child in self.get_children():
                if child is CollisionShape3D:
                    child.global_position.z += collision_size.z
                    # print("3")
        _:
            # print("why")
            pass    

func _on_ent_entered(ent: Node) -> void:
    print("LADDER:climb")

func _on_ent_exited(ent: Node) -> void:
    print("LADDER:exit")