extends HBoxContainer
const MODULE_NAME = "ImageBox"
var logger = LogWriter.new()

@onready var imageLoaderNode = get_node("..")

func _ready():
	SignalBus.image_selected.connect(_on_image_selected)
	SignalBus.image_deselected.connect(_on_image_deselected)

func addImageNode(node):
	add_child(node)

# From instantiated Image nodes
func _on_image_selected(value):
	if imageLoaderNode.someImagesAreSelected():
		SignalBus.emit_signal("some_images_selected")
	else:
		SignalBus.emit_signal("no_images_selected")

func _on_image_deselected(value):
	if imageLoaderNode.someImagesAreSelected():
		SignalBus.emit_signal("some_images_selected")
	else:
		SignalBus.emit_signal("no_images_selected")
