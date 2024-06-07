extends Node
const MODULE_NAME = "Main"
var logger = LogWriter.new()

@onready var confirmWindowNode = get_node("ConfirmDeleteWindow")
@onready var imageLoaderNode = get_node("MarginContainer/MarginContainer/ImageLoader")

var dupes = []
var commits = []
var writeFilenames: bool = true

func _ready():
	SignalBus.delete_pressed.connect(_on_control_panel_delete_pressed)
	SignalBus.delete_mode_toggled.connect(_on_delete_mode_toggled)

func dupeToFilename(index: int):
	return dupes[index]["Folder"].path_join(dupes[index]["Filename"])

########################################

func _on_delete_mode_toggled(pressed: bool):
	writeFilenames = pressed

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
	if writeFilenames:
		var datetime_string = Time.get_unix_time_from_system()
		var newFilename = Data.EXTERNAL_ASSETS_FOLDER.path_join("%s.txt" % datetime_string)
		var newFile = FileAccess.open(newFilename, FileAccess.WRITE)
		for f in files:
			newFile.store_line(f)
	else:
		for f in files:
			if Utils.fileExistsAtLocation(f):
				print("Deleting %s" % f)
				OS.move_to_trash(f)
	SignalBus.delete_confirmed.emit()
