extends PanelContainer

@onready var propertiy_container = %debug_VBoxContainer

# var propertiy
var frames_pre_second : String

func _ready():
    Global.debug_panel = self

func _process(delta):
    if (visible):
        frames_pre_second = "%.2f" % (1.0/delta)
        add_property("fps",frames_pre_second,0)

func _input(event):
    if (Input.is_action_just_pressed("debug_info")):
        if %debug_VBoxContainer.visible == true :
            %debug_VBoxContainer.hide()
        else :
            %debug_VBoxContainer.show()

func add_property(title : String , value, order):
    var target
    target = propertiy_container.find_child(title, true, false)
    if (!target):
        target = Label.new()
        propertiy_container.add_child(target)
        target.name = title
        target.text = target.name + ":  " + str(value)
    elif visible:
        target.text = title + ":  " + str(value)
        propertiy_container.move_child(target, order)
