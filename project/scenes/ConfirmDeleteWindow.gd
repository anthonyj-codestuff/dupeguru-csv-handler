extends ConfirmationDialog
const MODULE_NAME = "ConfirmDeleteWindow"
var logger = LogWriter.new()

@onready var textNode = get_node("VBoxContainer/MarginContainer/ScrollContainer/RichTextLabel")

func setWindowProperties(text: String):
	self.visible = true
	textNode.text = text

func _on_check_box_toggled(button_pressed):
	SignalBus.delete_mode_toggled.emit(button_pressed)
