extends ConfirmationDialog
const MODULE_NAME = "ConfirmDeleteWindow"
var logger = LogWriter.new()

@onready var textNode = get_node("VBoxContainer/MarginContainer/ScrollContainer/RichTextLabel")
@onready var jsonHboxNode = get_node("VBoxContainer/HBoxJSON")
@onready var jsonCheckboxNode = get_node("VBoxContainer/HBoxJSON/JSONCheckBox")

func setWindowProperties(text: String):
	self.visible = true
	textNode.text = text

func _on_save_check_box_toggled(button_pressed):
	SignalBus.delete_mode_toggled.emit(button_pressed)
	if button_pressed:
		# if delete mode is enabled, enable json deletion in an unticked state
		jsonCheckboxNode.button_pressed = false
		jsonHboxNode.visible = true
		SignalBus.delete_json_mode_toggled.emit(false)
	else:
		jsonCheckboxNode.button_pressed = false
		jsonHboxNode.visible = false
		SignalBus.delete_json_mode_toggled.emit(false)

func _on_json_check_box_toggled(button_pressed):
	SignalBus.delete_json_mode_toggled.emit(button_pressed)
