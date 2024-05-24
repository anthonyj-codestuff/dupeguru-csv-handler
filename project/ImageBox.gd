extends HBoxContainer
const MODULE_NAME = "ImageBox"
var logger = LogWriter.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func addImageNode(node):
	add_child(node)
	pass
