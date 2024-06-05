extends Node
const MODULE_NAME = "Main"
var logger = LogWriter.new()

@onready var confirmWindowNode = get_node("ConfirmDeleteWindow")
@onready var imageLoaderNode = get_node("MarginContainer/MarginContainer/ImageLoader")

var dupes = []
var commits = []

func _ready():
	SignalBus.delete_pressed.connect(_on_control_panel_delete_pressed)

func dupeToFilename(index: int):
	return dupes[index]["Folder"].path_join(dupes[index]["Filename"])

########################################

func _on_control_panel_delete_pressed():
	dupes = imageLoaderNode.dupeData
	commits = imageLoaderNode.committedImages
	var filenames: Array[String] = []
	for i in commits:
		var filename = dupeToFilename(i)
		if Utils.fileExistsAtLocation(filename):
			filenames.append(Utils.getFilepathByLayers(filename, 3))
		else:
			filenames.append("[ALREADY DELETED] %s" % Utils.getFilepathByLayers(filename, 3))
	confirmWindowNode.setWindowProperties("\n".join(filenames))

func _on_confirm_delete_window_confirmed():
	var files = []
	for i in commits:
		files.append(dupeToFilename(i))
	for f in files:
		if Utils.fileExistsAtLocation(f):
			print("Deleting %s" % f)
			OS.move_to_trash(f)
		else:
			print("Skipping %s" % f)
