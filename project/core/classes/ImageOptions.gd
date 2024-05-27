class_name ImageOptions extends RefCounted
const MODULE_NAME = "ImageOptions"
var logger = LogWriter.new()

var dictIndex: int = 0
var groupId: int = 0
var imageFilename: String = ""
var imageFolder: String = ""
var fileSizeKB: int = 0
var modificationDateReadable: String = ""
var matchPercent: int = 0

var imageFilepath: String = ""
var modificationDateUnix: int
var initLoadingError: bool = false
var selected: bool = false

func _init(index, values: Dictionary):
	if not index and index != 0 or not index is int:
		logger.error("index value not found ["+str(values.index)+"]", MODULE_NAME)
		initLoadingError = true
	else:
		dictIndex = index

	if not values["Group ID"] and values["Group ID"] != 0 or not values["Group ID"] is int:
		logger.error("group id value not found ["+str(values["Group ID"])+"]", MODULE_NAME)
		initLoadingError = true
	else:
		groupId = values["Group ID"]

	if not values["Filename"] or not values["Filename"] is String:
		logger.error("filename value not found ["+str(values["Filename"])+"]", MODULE_NAME)
		initLoadingError = true
	else:
		imageFilename = values["Filename"]

	if not values["Folder"] or not values["Folder"] is String:
		logger.error("folder value not found ["+str(values["Folder"])+"]", MODULE_NAME)
		initLoadingError = true
	else:
		imageFolder = values["Folder"]

	if not values["Size (KB)"] or not values["Size (KB)"] is int:
		logger.error("file size value not found ["+str(values["Size (KB)"])+"]", MODULE_NAME)
		initLoadingError = true
	else:
		fileSizeKB = values["Size (KB)"]

	if not values["Modification"] or not values["Modification"] is String or not Utils.stringIsValidDatetime(values["Modification"]):
		logger.error("modification time value not found ["+str(values["Modification"])+"]", MODULE_NAME)
		initLoadingError = true
	else:
		modificationDateReadable = values["Modification"]

	if not values["Match %"] or not values["Match %"] is int:
		logger.error("match percentage value not found ["+str(values["Match %"])+"]", MODULE_NAME)
		initLoadingError = true
	else:
		matchPercent = values["Match %"]

	if not imageFolder.length() or not imageFilename.length():
		logger.error("invalid file path elements ["+str(imageFolder)+", "+str(imageFilename)+"]", MODULE_NAME)
		initLoadingError = true
	else:
		imageFilepath = imageFolder.path_join(imageFilename)

	if not modificationDateReadable or not Utils.stringIsValidDatetime(modificationDateReadable):
		logger.error("invalid modification date ["+str(modificationDateReadable)+"]", MODULE_NAME)
		initLoadingError = true
	else:
		var dateAndTime = modificationDateReadable.split(" ")
		dateAndTime[0] = dateAndTime[0].replace("/", "-")
		var ISO8601Datestring = "T".join(dateAndTime)
		modificationDateUnix = Time.get_unix_time_from_datetime_string(ISO8601Datestring)
	
	if initLoadingError:
		logger.error("error detected with dictionary ["+str(values)+"]", MODULE_NAME)
	else:
		logger.info("options for node "+str(dictIndex)+" loaded successfully", MODULE_NAME)
