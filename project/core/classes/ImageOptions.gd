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

# Extended values (requires gallery-dl)
var gdlParentJSONFilename: String
var gdlCreationDateReadable: String
var gdlCreationDateUnix: int
var gdlExternalUri: String

# Extended values (requires Python)
var pyCreationDateReadable: String
var pyCreationDateUnix: int

# Control variables
var initLoadingError: bool = false
var selected: bool = false
var fileExists: bool = false

var imageHostFolderNames = {
	"twitter": {"name": "twitter", "pattern": "/twitter/"},
	"mastodon": {"name": "mastodon", "pattern": "/mastodon/"},
	"pixiv": {"name": "pixiv", "pattern": "/pixiv/"},
	"e6ng": {"name": "e6ng", "pattern": "/e[0-9]{3}/|/e6ai/"}
}

func _init(index, values: Dictionary, python):
	if not index and index != 0 or not index is int:
		logger.error("index value not found ["+str(values.index)+"]", MODULE_NAME)
		initLoadingError = true
	else:
		dictIndex = index

	setRequiredValues(values)
	setOptionalValues(values)
	setDerivedValues(values)
	if imageFilepath and Utils.fileExistsAtLocation(imageFilepath):
		setExtendedStats(imageFilepath, python)

	if initLoadingError:
		logger.error("error detected with dictionary ["+str(values)+"]", MODULE_NAME)
	else:
		logger.info("options for node "+str(dictIndex)+" loaded successfully", MODULE_NAME)

func getUnixCreationDate():
	if gdlCreationDateUnix:
		return gdlCreationDateUnix
	elif pyCreationDateUnix:
		return pyCreationDateUnix
	else:
		return null

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

	fileExists = Utils.fileExistsAtLocation(imageFolder.path_join(imageFilename))

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
	var gdlstats = getFileProperties(filepath)
	var pystats = python.getFileProperties(filepath)
	if "gdlDateReadable" in gdlstats:
		gdlCreationDateReadable = gdlstats.gdlDateReadable
	if "gdlDateUnix" in gdlstats:
		gdlCreationDateUnix = gdlstats.gdlDateUnix
	if "externalUri" in gdlstats:
		gdlExternalUri = gdlstats.externalUri
	if "jsonFilename" in gdlstats:
		gdlParentJSONFilename = gdlstats.jsonFilename
	if "creationDateReadable" in pystats:
		pyCreationDateReadable = pystats.creationDateReadable
	if "creationDateUnix" in pystats:
		pyCreationDateUnix = pystats.creationDateUnix

	if "modificationDateReadable" in pystats and not modificationDateReadable:
		modificationDateReadable = pystats.modificationDateReadable
	if "modificationDateUnix" in pystats and not modificationDateUnix:
		modificationDateUnix = pystats.modificationDateUnix
	if "imageWidth" in pystats and (not imageWidth or imageWidth != pystats.imageWidth):
		logger.info("overriding image [%s] width from [%s] to [%s]" % [imageFilename, imageWidth, pystats.imageWidth], MODULE_NAME)
		imageWidth = pystats.imageWidth
	if "imageHeight" in pystats and (not imageHeight or imageHeight != pystats.imageHeight):
		logger.info("overriding image [%s] height from [%s] to [%s]" % [imageFilename, imageHeight, pystats.imageHeight], MODULE_NAME)
		imageHeight = pystats.imageHeight
	imageDimensionsReadable = "%s x %s" % [imageWidth, imageHeight]

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
	if gdlCreationDateReadable:
		strings.append("Created At: %s" % gdlCreationDateReadable)
	if pyCreationDateReadable and not gdlCreationDateReadable:
		strings.append("Created At: %s" % pyCreationDateReadable)
	if modificationDateReadable:
		strings.append("Modified At: %s" % modificationDateReadable)
	if matchPercent or matchPercent is int:
		strings.append("Match Percent: %s%%" % matchPercent)
	if imageWidth and imageWidth is int and not imageDimensionsReadable:
		strings.append("Width: %spx" % imageWidth)
	if imageHeight and imageHeight is int and not imageDimensionsReadable:
		strings.append("Height: %spx" % imageHeight)
	return "\n".join(strings)

# # # # # # # # # # # #
# Gallery-dl Functions

func isGallerydlAsset(filename: String)->bool:
	return Utils.stringMatchesRegex(filename, "^.*-\\d{1,20}\\.(png|jpg|jpeg|mp4)$")

func getFileProperties(filepath: String):
	var filename = filepath.get_file()
	var hostType = getImageHostFromFilepath(filepath)
	var json: Dictionary = getGallerydlJSONForImageFilepath(filepath, hostType)
	var idString

	if json.has("JSONRawString") and hostType == imageHostFolderNames["twitter"]["name"]:
		idString = getBigNumberValueFromJsonString(json["JSONRawString"], "tweet_id")
	elif json.has("JSONRawString") and hostType == imageHostFolderNames["mastodon"]["name"]:
		idString = getBigNumberValueFromJsonString(json["JSONRawString"], "id")
	elif json.has("JSONRawString") and hostType == imageHostFolderNames["pixiv"]["name"]:
		idString = getBigNumberValueFromJsonString(json["JSONRawString"], "id")
	elif json.has("JSONRawString") and hostType == imageHostFolderNames["e6ng"]["name"]:
		idString = getBigNumberValueFromJsonString(json["JSONRawString"], "id")
	else:
		idString = ""

	if json.has("date") and json.has("JSONFilename"):
		var dateFormatted = json["date"].replace("-", "/")
		var properties = {
			"gdlDateReadable": dateFormatted,
			"gdlDateUnix": Time.get_unix_time_from_datetime_string(json["date"]),
			"jsonFilename": json["JSONFilename"],
		}
		# if the hand-extracted id doesn't match, then something happened with the floating-point conversion
		# use the string instead
		if hostType == imageHostFolderNames["twitter"]["name"]:
			var tweetId = idString if idString and idString != str(json["tweet_id"]) else json["tweet_id"]
			properties.externalUri = "https://twitter.com/%s/status/%s" % [json["author"]["name"], tweetId]
		elif hostType == imageHostFolderNames["mastodon"]["name"]:
			properties.externalUri = json["url"]
		elif hostType == imageHostFolderNames["pixiv"]["name"]:
			properties.externalUri = "https://www.pixiv.net/en/artworks/%s" % [json["id"]]
		elif hostType == imageHostFolderNames["e6ng"]["name"]:
			properties.externalUri = "https://%s.net/posts/%s" % [json["category"], json["id"]]

		return properties
	return {}

func getGallerydlJSONForImageFilepath(imageFilepath: String, hostType: String)->Dictionary:
	var imageFilename = imageFilepath.get_file()
	if not isGallerydlAsset(imageFilename):
		logger.info("filename [%s] is not a gallery-dl asset" % imageFilename, MODULE_NAME)
		return {}
	var path = imageFilepath.get_base_dir()
	var baseFilename
	if hostType in ["twitter", "mastodon", "pixiv"]:
		var rindex = imageFilename.rfind("-")
		if rindex != -1:
			baseFilename = imageFilename.left(rindex)
		else:
			logger.info("filename [%s] does not meet requirements" % imageFilename, MODULE_NAME)
			return {}
	elif hostType in ["e6ng"]:
		# e6ng sites do not allow multiple images per post, use the base name
		var extension = imageFilename.get_extension()
		var rindex = imageFilename.rfind(extension)
		if rindex < 0:
			return {}
		baseFilename = imageFilename.left(rindex-1)
	else:
		logger.warn("host type [%s] is not supported. Cannot find JSON" % hostType, MODULE_NAME)
		return {}
	
	var jsonFilename = baseFilename + ".json"
	var jsonFilepath = path.path_join(jsonFilename)
	if Utils.fileExistsAtLocation(jsonFilepath):
		var json_text = FileAccess.get_file_as_string(jsonFilepath)
		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			var data_received = json.data
			if typeof(data_received) == TYPE_DICTIONARY:
				# pop this on there so we can save it
				data_received["JSONFilename"] = jsonFilename
				data_received["JSONRawString"] = json_text
				return data_received
			else:
				logger.error("Unexpected data when parsing JSON file [%s]" % jsonFilename, MODULE_NAME)
		else:
			logger.error("JSON Parse Error: [%s] in [%s] at line [%s]" % [json.get_error_message(), jsonFilename, json.get_error_line()], MODULE_NAME)
	return {}

func getImageHostFromFilepath(imageFilepath: String)->String:
	for i in imageHostFolderNames.keys():
		if Utils.stringMatchesRegex(imageFilepath, imageHostFolderNames[i]["pattern"]):
			return i
	return ""

# needed because JSON parsing casts number to float before int, so very large numbers get altered
func getBigNumberValueFromJsonString(jsonString: String, key: String):
	var result = ""
	# start by finding the index of the key
	var index = jsonString.find(key)
	if index == -1:
		return result

	var numerals = ""
	# move the index to the next valid digit after the current index
	while index < jsonString.length() and not jsonString[index].is_valid_int():
		index += 1

	# now loop until we find the first non-digit
	while index < jsonString.length():
		var char = jsonString.substr(index, 1)
		if char.is_valid_int():
			numerals += char
		else:
			break
		index += 1
	if numerals.is_valid_int():
		return numerals
	else:
		return result
