extends Node
const MODULE_NAME = "SignalBus"
var logger = LogWriter.new()
# checked when an image is de/selected or staged for deletion
# used to control which buttons are disabled
signal no_images_selected
signal some_images_selected
signal no_deletes_committed
signal some_deletes_committed

# fires any time an imge is manually toggled by the user
signal image_selected
signal image_deselected

# ControlPanel signals emitted when buttons are pressed
signal select_all_pressed
signal select_none_pressed
signal left_pressed
signal right_pressed
signal commit_pressed
signal undo_pressed
signal delete_pressed

# Miscellaneous
signal delete_mode_toggled
signal delete_confirmed
