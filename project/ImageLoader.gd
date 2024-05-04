extends Node2D

const path = "/Users/anthonyjett/Documents/Godot/My Projects/240429-Dupe CSV Handler/external_assets"
var images = []
var extensions: Array[String] = ["jpg", "jpeg", "png"]
var index = 0
var textureNode
var labelNode

# Called when the node enters the scene tree for the first time.
func _ready():
	var options = {
		"delim": ",",
		"detect_numbers": true,
		"headers": true,
		"force_float": false
	}
	var dupeData = importCSV(Data.CSV_ASSET_PATH, options)
	if dupeData[0] != Data.CSV_FOOTPRINT:
		printerr("File does not match expected footprint")
		return
	textureNode = get_node("PanelContainer/TextureRect")
	labelNode = get_node("Label")
	images = getAllFilePaths(path, extensions)
	images.sort()
	loadImageFile(images[0])
	labelNode.text = "%s: %s" % ["0", images[0]]

func importCSV(source_file, options):
	var file = FileAccess.open(source_file, FileAccess.READ)
	if not file:
		printerr("Failed to open file: ", source_file)
		return

	var lines = []
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

func getAllFilePaths(path: String, exts: Array[String]) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			file_paths += getAllFilePaths(file_path, exts)
		else:
			if extensions.has(file_path.get_extension()):
				file_paths.append(file_path)
			file_name = dir.get_next()
	return file_paths

func loadImageFile(path):
	var image_path = path
	var image = Image.new()
	image.load(image_path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	get_node("PanelContainer/TextureRect").texture = image_texture


func _on_left_pressed():
	if index == 0 and len(images) > 0:
		index = len(images)-1
	elif len(images) > 0:
		index -= 1
	loadImageFile(images[index])
	labelNode.text = "%s: %s" % [str(index), images[index]]
	pass

func _on_right_pressed():
	if index == len(images)-1 and len(images) > 0:
		index = 0
	elif len(images) > 0:
		index += 1
	loadImageFile(images[index])
	labelNode.text = "%s: %s" % [str(index), images[index]]
	pass
