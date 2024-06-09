extends Node
const MODULE_NAME = "Utils"
var logger = LogWriter.new()

func replaceWindowsBackslashes(string: String):
	if not string.is_valid_int() and OS.has_feature("windows"):
		return string.replace("\\", "/")
	return string

func importCSV(source_file, options, errorLabelNode):
	var handleImportedCSV = func(data, errors = []):
		var headers: Array = data[0] if data.size() else []
		# if the CSV file does not have the absolutely necessary keys,
		# post an error message and delete the loaded CSV data
		if not Data.CSV_FOOTPRINT_MVP.all(func(key): return headers.has(key)):
			var missingKeys = Data.CSV_FOOTPRINT_MVP.filter(func(key): return not headers.has(key))
			var missingKeysStr = ", ".join(missingKeys)
			errors.append("CSV file does not have expected minimum footprint. Missing keys [%s]\n" % missingKeysStr)
			data = []
		errors = errors.map(func(e): return "- " + e)
		errorLabelNode.text = "\n".join(errors)
		
		# Remove CSV header, it will only get in the way
		data.pop_front()
		return data

	if not Utils.fileExistsAtLocation(Data.CSV_FILE_PATH):
		var error = "CSV file not found. Export \"dupes.csv\" from DupeGuru, copy it into external_assets/ and try again."
		return handleImportedCSV.call([], [error])
	# TODO sort the array by group ID just in case, a lot of logic depends on that
	var file = FileAccess.open(source_file, FileAccess.READ)
	if not file:
		var error = "Failed to open file: %s" % source_file
		logger.error(error, MODULE_NAME)
		return handleImportedCSV.call([], [error])

	var lines = []
	# load each line to the array
	while not file.eof_reached():
		var line = file.get_csv_line(options.delim)
		if not (line.size() == 1 and line[0].is_empty()):
			if options.detect_numbers and (not options.headers or lines.size() > 0):
				var detected := []
				for field in line:
					field = replaceWindowsBackslashes(field)
					if not options.force_float and field.is_valid_int():
						detected.append(int(field))
					elif field.is_valid_float():
						detected.append(float(field))
					else:
						detected.append(field)
				lines.append(detected)
			else:
				for field in line:
					field = replaceWindowsBackslashes(field)
				lines.append(line)
	file.close()

	# Remove trailing empty line
	if not lines.is_empty() and lines.back().size() == 1 and lines.back()[0] == "":
		lines.pop_back()

	if options.headers:
		if lines.is_empty():
			var error = "Can't find header in empty file"
			logger.error(error, MODULE_NAME)
			return handleImportedCSV.call([], [error])

		var headers = lines[0]
		for i in range(1, lines.size()):
			var fields = lines[i]
			if fields.size() > headers.size():
				var error = "Line %d has more fields than headers" % i
				logger.error(error, MODULE_NAME)
				return handleImportedCSV.call([], [error])
			var dict = {}
			for j in headers.size():
				var name = headers[j]
				var value = fields[j] if j < fields.size() else null
				dict[name] = value
			lines[i] = dict
		# If import is successful, pass the array and pass any errors to the user
		return handleImportedCSV.call(lines)
	else:
		var error = "CSV parsed without checking headers. This is probably a configuration mistake"
		logger.warn(error, MODULE_NAME)
		return handleImportedCSV.call(lines, [error])

func printFilesInDirectory(path):
	var Logger = LogWriter.new()
	var dir := DirAccess.open(path)
	if dir:
		if dir.list_dir_begin() == OK:
			while true:
				var file = dir.get_next()
				if file == "":
					break
				elif not file.begins_with("."): # This would be a directory
					Logger.info(file, MODULE_NAME)
			dir.list_dir_end()
		else:
			logger.error("Could not open the directory " + path, MODULE_NAME)
	else:
		logger.error("Could not load the path " + path, MODULE_NAME)

func getFilepathByLayers(path: String, layers: int):
	var fileLayers = path.split("/")
	if fileLayers.size() > layers:
		return "/".join(fileLayers.slice(fileLayers.size()-layers, fileLayers.size()))
	else:
		return path

func loadImageToTexture(path: String)->ImageTexture:
	var image_texture = ImageTexture.new()
	if(fileExistsAtLocation(path)):
		var image = Image.new()
		image.load(path)
		image_texture.set_image(image)
	else:
		var texture: CompressedTexture2D = load("res://assets/notfound.png")
		var image: Image = texture.get_image()
		image_texture.set_image(image)
	return image_texture

func fileExistsAtLocation(path: String):
	return FileAccess.file_exists(path)

func stringMatchesRegex(string: String, pattern: String)->bool:
	var regex = RegEx.new()
	regex.compile(pattern)
	var result = regex.search(string)
	if result:
		return true
	return false

func getBareImageName(filepath: String)->String:
	var filename = filepath.get_file().get_slice(".", 0)
	return filename.rsplit("-", true, 1)[0]

func mapOutOfBoundsIndex(arrayLength: int, badIndex: int)->int:
	if arrayLength <= 0:
		logger.warn("cannot adjust out-of-bounds index for zero-length array" % [badIndex, arrayLength], MODULE_NAME)
		return badIndex
	if badIndex >= 0 and badIndex < arrayLength:
		logger.info("index [%s] is not out-of-bounds for array of length [%s]" % [badIndex, arrayLength], MODULE_NAME)
		return badIndex
	# If the user requests to skip groups while seeking, it is possible to move
	# the currentIndex well beyond the length of the array. If this happens,
	# loop back to the beginning and displace by the remainder
	# ex. [0,1,2,3,4,5],-,-,-,-,-,-,-,-,X (User was at index 5 and requested index 14)
	#     [0,1,2,3,4,5],-,-,X (reduced by the len, but still out-of-bounds at 8)
	#     [0,1,X,3,4,5] (index is within bounds, return 2)
	#     X,-,-,-,-,-,-,-,-,[0,1,2,3,4,5] -> (-9)
	#     X,-,-,[0,1,2,3,4,5] -> (-3)
	#     [0,1,2,X,4,5] -> (3)
	var foundGoodIndex = false
	var newIndex = badIndex
	if newIndex >= arrayLength:
		while not foundGoodIndex:
			newIndex -= arrayLength
			if newIndex < 0:
				logger.error("cannot find good next value for index [%s] and array of length [%s]" % [badIndex, arrayLength], MODULE_NAME)
				return badIndex
			if newIndex < arrayLength-1:
				foundGoodIndex = true
		return newIndex
	elif newIndex < 0:
		while not foundGoodIndex:
			newIndex += arrayLength
			if newIndex >= arrayLength:
				logger.error("cannot find good previous value for index [%s] and array of length [%s]" % [badIndex, arrayLength], MODULE_NAME)
				return badIndex
			if newIndex < arrayLength:
				foundGoodIndex = true
		return newIndex
	else:
		logger.error("reached unreachable code for index [%s] and array of length [%s]" % [badIndex, arrayLength], MODULE_NAME)
		return badIndex
