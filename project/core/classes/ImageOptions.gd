class_name ImageOptions extends RefCounted
const MODULE_NAME = "ImageOptions"
var logger = LogWriter.new()

# Minimum values directly from CSV
var groupId: int
var imageFilename: String
var imageFolder: String
# Optional values directly from CSV
var fileSizeKB: int
var imageDimensionsReadable: String
var modificationDateReadable: String
var matchPercent: int

# Derived and context-specific values
var dictIndex: int
var imageFilepath: String
var imageFiletype: String
var imageWidth: int
var imageHeight: int
var modificationDateUnix: int

# Extended values (requires Python)
var pyCreationDateReadable: String
var pyCreationDateUnix: int

# Control variables
var initLoadingError: bool = false
var selected: bool = false
var fileExists: bool = false

func _init(index, values: Dictionary, python):
	if not index and index != 0 or not index is int:
		logger.error("index value not found ["+str(values.index)+"]", MODULE_NAME)
		initLoadingError = true
	else:
		dictIndex = index

	setRequiredValues(values)
	setOptionalValues(values)
	setDerivedValues(values)
	if imageFilepath:
		setExtendedStats(imageFilepath, python)

	if initLoadingError:
		logger.error("error detected with dictionary ["+str(values)+"]", MODULE_NAME)
	else:
		logger.info("options for node "+str(dictIndex)+" loaded successfully", MODULE_NAME)

func setRequiredValues(values):
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

	fileExists = FileAccess.file_exists(imageFolder.path_join(imageFilename))

func setOptionalValues(values):
	if not values["Size (KB)"] or not values["Size (KB)"] is int:
		logger.warn("file size value not found ["+str(values["Size (KB)"])+"]", MODULE_NAME)
	else:
		fileSizeKB = values["Size (KB)"]

	if not values["Dimensions"] or not values["Dimensions"] is String:
		logger.warn("image dimensions value not found ["+str(values["Dimensions"])+"]", MODULE_NAME)
	else:
		imageDimensionsReadable = values["Dimensions"]

	if not values["Modification"] or not values["Modification"] is String or not Utils.stringMatchesRegex(values["Modification"], "\\d{4}/\\d{2}/\\d{2} \\d{2}:\\d{2}:\\d{2}"):
		logger.warn("modification time value not found ["+str(values["Modification"])+"]", MODULE_NAME)
	else:
		modificationDateReadable = values["Modification"]

	if not values["Match %"] or not values["Match %"] is int:
		logger.warn("match percentage value not found ["+str(values["Match %"])+"]", MODULE_NAME)
	else:
		matchPercent = values["Match %"]

func setDerivedValues(values):
	if not imageFolder.length() or not imageFilename.length():
		logger.warn("invalid file path elements ["+str(imageFolder)+", "+str(imageFilename)+"]", MODULE_NAME)
	else:
		imageFilepath = imageFolder.path_join(imageFilename)

	if not imageFilename.length():
		logger.warn("invalid file name ["+str(imageFilename)+"]", MODULE_NAME)
	else:
		imageFiletype = imageFilename.split(".")[-1]

	if not imageDimensionsReadable or not Utils.stringMatchesRegex(imageDimensionsReadable, "\\d{1,5} x \\d{1,5}"):
		# true if time string matches "##### x #####"
		logger.warn("invalid image dimensions ["+str(imageDimensionsReadable)+"]", MODULE_NAME)
	else:
		var dimensions = imageDimensionsReadable.split(" x ")
		imageWidth = int(dimensions[0])
		imageHeight = int(dimensions[1])

	if not modificationDateReadable or not Utils.stringMatchesRegex(modificationDateReadable, "\\d{4}/\\d{2}/\\d{2} \\d{2}:\\d{2}:\\d{2}"):
		# true if time string matches "YYYY/MM/DD HH:MM:SS"
		logger.warn("invalid modification date ["+str(modificationDateReadable)+"]", MODULE_NAME)
	else:
		var dateAndTime = modificationDateReadable.split(" ")
		dateAndTime[0] = dateAndTime[0].replace("/", "-")
		var ISO8601Datestring = "T".join(dateAndTime)
		modificationDateUnix = Time.get_unix_time_from_datetime_string(ISO8601Datestring)

func setExtendedStats(filepath, python):
	var stats = python.getFileProperties(filepath)
	if "creationDateReadable" in stats:
		pyCreationDateReadable = stats.creationDateReadable
	if "creationDateUnix" in stats:
		pyCreationDateUnix = stats.creationDateUnix
	if "modificationDateReadable" in stats and not modificationDateReadable:
		modificationDateReadable = stats.modificationDateReadable
	if "modificationDateUnix" in stats and not modificationDateUnix:
		modificationDateUnix = stats.modificationDateUnix
	if "imageWidth" in stats and not imageWidth:
		imageWidth = stats.imageWidth
	if "imageHeight" in stats and not imageHeight:
		imageHeight = stats.imageHeight
	if "imageDimensionsReadable" in stats and not imageDimensionsReadable:
		imageDimensionsReadable = stats.imageDimensionsReadable

func getStatsReadableString():
	var strings = []
	if dictIndex or dictIndex is int:
		strings.append("Index: %s" % dictIndex)
	if groupId or groupId is int:
		strings.append("Group Id: %s" % groupId)
	if imageFilename:
		strings.append("Filename: %s" % imageFilename)
	if fileSizeKB or fileSizeKB is int:
		strings.append("Size: %s KB" % fileSizeKB)
	if imageDimensionsReadable:
		strings.append("Dimensions: %s" % imageDimensionsReadable)
	if pyCreationDateReadable:
		strings.append("Created At: %s" % pyCreationDateReadable)
	if modificationDateReadable:
		strings.append("Modified At: %s" % modificationDateReadable)
	if matchPercent or matchPercent is int:
		strings.append("Match Percent: %s%%" % matchPercent)
	if imageWidth and imageWidth is int:
		strings.append("Width: %spx" % imageWidth)
	if imageHeight and imageHeight is int:
		strings.append("Height: %spx" % imageHeight)
	return "\n".join(strings)
