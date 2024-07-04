extends Node
const MODULE_NAME = "Main"
var logger = LogWriter.new()

@onready var confirmWindowNode = get_node("ConfirmDeleteWindow")
@onready var imageLoaderNode = get_node("MarginContainer/MarginContainer/ImageLoader")

var dupes = []
var commits = []
var deleteFiles: bool = false
var deleteGallerydlMetadata: bool = false

func _ready():
	SignalBus.delete_pressed.connect(_on_control_panel_delete_pressed)
	SignalBus.delete_mode_toggled.connect(_on_delete_mode_toggled)
	SignalBus.delete_json_mode_toggled.connect(_on_delete_json_mode_toggled)

func dupeToFilename(index: int):
	return dupes[index]["Folder"].path_join(dupes[index]["Filename"])

########################################

func _on_delete_mode_toggled(pressed: bool):
	deleteFiles = pressed
	if pressed:
		confirmWindowNode.ok_button_text = "Delete All"
	else:
		confirmWindowNode.ok_button_text = "Save Filenames"

func _on_delete_json_mode_toggled(pressed: bool):
	deleteGallerydlMetadata = pressed

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
	SignalBus.show_progress_bar.emit()
	for i in commits:
		files.append(dupeToFilename(i))
	if deleteFiles:
		for i in range(files.size()):
			if Utils.fileExistsAtLocation(files[i]):
				logger.warn("deleting image - %s" % files[i], MODULE_NAME)
				OS.move_to_trash(files[i])
				SignalBus.set_progress_bar.emit((i+1)*100/files.size())
				await get_tree().process_frame
		if deleteGallerydlMetadata:
			await deleteAbandonedMetadataForDeletedFiles(files)
	else:
		var datetime_string = Time.get_unix_time_from_system()
		var newFilename = Data.EXTERNAL_ASSETS_FOLDER.path_join("%s.txt" % datetime_string)
		var newFile = FileAccess.open(newFilename, FileAccess.WRITE)
		for f in files:
			newFile.store_line(f)
	SignalBus.hide_progress_bar.emit()
	SignalBus.delete_confirmed.emit()

func _on_confirm_delete_window_canceled():
	SignalBus.delete_cancelled.emit()

# TODO This is pretty expensive. There's got to be a cheaper faster way to do this
# A CSV could point to several different directories in the same go, and we don't want to search every directory every step
# since images should always be in the same place that their metadata is located
# Key = /the/base/directory/of/the/ file for easy lookup
# Value = A list of all files left in the directory after delete has taken place
func deleteAbandonedMetadataForDeletedFiles(filepaths: Array)->void:
	var directoriesToSearch = {}
	var filesToDelete = []
	SignalBus.set_secondary_progress_bar.emit()
	for filepath in filepaths:
		var directory = filepath.get_base_dir()
		if not directory in directoriesToSearch:
			var files = Array(DirAccess.get_files_at(directory))
			directoriesToSearch[directory] = files
		var baseFilename = Utils.getBareImageName(filepath)
		var matches = directoriesToSearch[directory].filter(func(f): return f.contains(baseFilename))
		if matches.all(func(f): return f.ends_with(".json")):
			for i in matches:
				filesToDelete.append(directory.path_join(i))
	for i in range(filesToDelete.size()):
		logger.info("deleting json - %s" % filesToDelete[i], MODULE_NAME)
		OS.move_to_trash(filesToDelete[i])
		SignalBus.set_progress_bar.emit((i+1)*100/filesToDelete.size())
		await get_tree().process_frame
