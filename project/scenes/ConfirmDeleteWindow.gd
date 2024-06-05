extends ConfirmationDialog
const MODULE_NAME = "ConfirmDeleteWindow"
var logger = LogWriter.new()

@onready var textNode = get_node("VBoxContainer/MarginContainer/ScrollContainer/RichTextLabel")

func setWindowProperties(text: String):
	self.visible = true
	textNode.text = text
