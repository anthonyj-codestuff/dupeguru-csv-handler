extends Node2D

const path = "/Users/anthonyjett/Documents/Godot/My Projects/240429-Dupe CSV Handler/external_assets"
var ImageBlock = preload("res://Image.tscn")
var dupeData = []
var extensions: Array[String] = ["jpg", "jpeg", "png"]
var options = {
		"delim": ",",
		"detect_numbers": true,
		"headers": true,
		"force_float": false
	}
var currentGroup = 0
var hBoxNode
var labelNode

# Called when the node enters the scene tree for the first time.
func _ready():
	labelNode = get_node("Label")
	hBoxNode = get_node("HBox")
	dupeData = Utils.importCSV(Data.CSV_ASSET_PATH, options)
	if dupeData[0] != Data.CSV_FOOTPRINT:
		printerr("File does not match expected footprint")
		return

	# Find first index with a group id
	currentGroup = getNextGroupIndex(currentGroup)
	loadImageNodesByGroup(currentGroup)

func loadImageNodesByGroup(index: int):
	var newNode = ImageBlock.instantiate()
	var dict = dupeData[index]
	var imagePath = dict["Folder"] + "/" + dict["Filename"]
	newNode.setImgProperties(imagePath, 200, 200)
	add_child(newNode)
	pass

func loadImageFile(path: String, node: Node):
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	node.texture = image_texture

func loadImageGroup():
	pass
	
func getNextGroupIndex(currentIndex: int):
	var index = currentIndex
	# Get the next index that is not a header (plaintext)
	# and is not the current index
	var foundNewIndex:bool = false
	while not foundNewIndex:
		index += 1
		var indexIsDictionary = dupeData[index] is Dictionary
		var indexHasInt = dupeData[index]["Group ID"] is int
		var indexIsDifferent = index != currentIndex
		if indexIsDictionary and indexHasInt and indexIsDifferent:
			foundNewIndex = true
	# TODO this will fail if it goes outside the range of the array
	return index
	

func _on_left_pressed()->void:
	if currentGroup == 0 and len(dupeData) > 0:
		currentGroup = len(dupeData)-1
	elif len(dupeData) > 0:
		currentGroup -= 1
	setLabel("%s: %s" % [str(currentGroup), dupeData[currentGroup]])
	pass

func _on_right_pressed()->void:
	if currentGroup == len(dupeData)-1 and len(dupeData) > 0:
		currentGroup = 0
	elif len(dupeData) > 0:
		currentGroup += 1
	setLabel("%s: %s" % [str(currentGroup), dupeData[currentGroup]])
	pass

func setLabel(str: String)->void:
	labelNode.text = str
	pass
