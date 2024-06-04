extends Control
const MODULE_NAME = "ControlPanel"
var logger = LogWriter.new()

@onready var commitNode = get_node("Commit")
@onready var undoNode = get_node("RightControls/VBoxContainer/MarginContainer/Undo")
@onready var deleteNode = get_node("RightControls/VBoxContainer/Delete")

func _ready():
	SignalBus.no_images_selected.connect(_on_image_loader_no_images_selected)
	SignalBus.some_images_selected.connect(_on_image_loader_some_images_selected)
	SignalBus.no_deletes_committed.connect(_on_image_loader_no_deletes_committed)
	SignalBus.some_deletes_committed.connect(_on_image_loader_some_deletes_committed)
	pass

# From ControlPanel
func _on_select_all_pressed():
	logger.info("emitting signal [select_all_pressed]", MODULE_NAME)
	SignalBus.emit_signal("select_all_pressed")

func _on_deselect_pressed():
	logger.info("emitting signal [select_none_pressed]", MODULE_NAME)
	SignalBus.emit_signal("select_none_pressed")

func _on_left_pressed():
	logger.info("emitting signal [left_pressed]", MODULE_NAME)
	SignalBus.emit_signal("left_pressed")

func _on_right_pressed():
	logger.info("emitting signal [right_pressed]", MODULE_NAME)
	SignalBus.emit_signal("right_pressed")

func _on_commit_pressed():
	logger.info("emitting signal [commit_pressed]", MODULE_NAME)
	SignalBus.emit_signal("commit_pressed")

func _on_undo_pressed():
	logger.info("emitting signal [undo_pressed]", MODULE_NAME)
	SignalBus.emit_signal("undo_pressed")

func _on_delete_pressed():
	logger.info("emitting signal [delete_pressed]", MODULE_NAME)
	SignalBus.emit_signal("delete_pressed")

# From ImageLoader
func _on_image_loader_no_images_selected():
	commitNode.disabled = true
	pass

func _on_image_loader_some_images_selected():
	commitNode.disabled = false
	pass

func _on_image_loader_no_deletes_committed():
	undoNode.disabled = true
	deleteNode.disabled = true
	pass

func _on_image_loader_some_deletes_committed():
	undoNode.disabled = false
	deleteNode.disabled = false
	pass
