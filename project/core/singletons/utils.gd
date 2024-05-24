extends Node
const MODULE_NAME = "Utils"
var logger = LogWriter.new()

func importCSV(source_file, options):
	# TODO sort the array by group ID just in case, a lot of logic depends on that
	var file = FileAccess.open(source_file, FileAccess.READ)
	listFilesInDirectory(Data.EXTERNAL_ASSETS_FOLDER)
	if not file:
		printerr("Failed to open file: ", source_file)
		return

	var lines = []
	# load each line to the array
	while not file.eof_reached():
		var line = file.get_csv_line(options.delim)
		if not (line.size() == 1 and line[0].is_empty()):
			if options.detect_numbers and (not options.headers or lines.size() > 0):
				var detected := []
				for field in line:
					if not options.force_float and field.is_valid_int():
						detected.append(int(field))
					elif field.is_valid_float():
						detected.append(float(field))
					else:
						detected.append(field)
				lines.append(detected)
			else:
				lines.append(line)
	file.close()

	# Remove trailing empty line
	if not lines.is_empty() and lines.back().size() == 1 and lines.back()[0] == "":
		lines.pop_back()

	if options.headers:
		if lines.is_empty():
			printerr("Can't find header in empty file")
			return ERR_PARSE_ERROR

		var headers = lines[0]
		for i in range(1, lines.size()):
			var fields = lines[i]
			if fields.size() > headers.size():
				printerr("Line %d has more fields than headers" % i)
				return ERR_PARSE_ERROR
			var dict = {}
			for j in headers.size():
				var name = headers[j]
				var value = fields[j] if j < fields.size() else null
				dict[name] = value
			lines[i] = dict
		return lines
	else:
		return lines
	pass

func listFilesInDirectory(path):
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
			print("Could not open the directory " + path)
	else:
		print("Could not load the path " + path)

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
