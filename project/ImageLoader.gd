extends Node2D

const path = "/Users/anthonyjett/Documents/Godot/My Projects/240429-Dupe CSV Handler/external_assets"
var ImageBlock = preload("res://Image.tscn")

# data from csv file
var dupeData = []
# storage for generated nodes
var imageNodes = []
# holding onto importand reference nodes
var hBoxNode
var labelNode

var currentIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	labelNode = get_node("Label")
	hBoxNode = get_node("HBox")
	dupeData = Utils.importCSV(Data.CSV_ASSET_PATH, Data.CSV_OPTIONS)
	if dupeData[0] != Data.CSV_FOOTPRINT:
		printerr("File does not match expected footprint")
		return

	# Find first index with a group id
	currentIndex = getNextGroupIndex(currentIndex)
	loadImageNodesByGroup(currentIndex)

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
	if currentIndex == 0 and len(dupeData) > 0:
		currentIndex = len(dupeData)-1
	elif len(dupeData) > 0:
		currentIndex -= 1
	setLabel("%s: %s" % [str(currentIndex), dupeData[currentIndex]])
	pass

func _on_right_pressed()->void:
	if currentIndex == len(dupeData)-1 and len(dupeData) > 0:
		currentIndex = 0
	elif len(dupeData) > 0:
		currentIndex += 1
	setLabel("%s: %s" % [str(currentIndex), dupeData[currentIndex]])
	pass

func setLabel(str: String)->void:
	labelNode.text = str
	pass
