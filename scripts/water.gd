@tool
extends CSGBox3D

@export var WATER_MOVE_SPEED := Vector3(.0025, .0025, .0025)
@export var WATER_SCALE := .04
@export var WATER_COLOR = Color(0.32, 0.609, 0.94, 0.498)

static var last_frame_drew_underwater_effect : int = -999

func _ready():
    self.process_priority = 999

func _process(delta):
    update_mesh()

    if self.material is StandardMaterial3D:
        # if not Engine.is_editor_hint():
        self.material.uv1_offset += WATER_MOVE_SPEED * delta
        self.material.albedo_color = WATER_COLOR

    if !Engine.is_editor_hint():
        if could_draw_camera_effect():
            %RippleOverlay.show()
            last_frame_drew_underwater_effect = Engine.get_process_frames()
        else :
            %RippleOverlay.hide()

func update_mesh():
    if get_node_or_null("%CollisionShape"):
        %CollisionShape.shape.size = self.size

func could_draw_camera_effect() -> bool:
    var camera := get_viewport().get_camera_3d() if get_viewport() else null
    if !camera :
        return false

    #aabb : axis-aligned bounding box
    #grow() : return a copy of extended on all side by the amount
    var aabb = self.global_transform * self.get_aabb().grow(.025)
    if !aabb.has_point(camera.global_position):
        return false

    %CameraPosCastShape.global_position = camera.global_position
    %CameraPosCastShape.force_shapecast_update()
    for i in %CameraPosCastShape.get_collision_count():
        if %CameraPosCastShape.get_collider(i) == %SwimmingArea:
            return true
    return false    