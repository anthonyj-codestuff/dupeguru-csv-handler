extends Control
const MODULE_NAME = "ImageLoader"
var ImageBlockPacked = preload("res://Image.tscn")
var logger = LogWriter.new()

# data from csv file
var dupeData = []
# storage for generated nodes
var imageNodes = []
# holding onto importand reference nodes
var imageBoxNode
var labelNode
# Indicates the 0th index of the current group
# if on group 2 of [0,0,1,1,2,2,3,3,3], index should be 4
var currentIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	labelNode = get_node("Label")
	imageBoxNode = get_node("ImageBox")
	dupeData = Utils.importCSV(Data.CSV_FILE_PATH, Data.CSV_OPTIONS)
	if dupeData[0] != Data.CSV_FOOTPRINT:
		printerr("File does not match expected footprint")
		return
	# Find first index with a group id
	currentIndex = getNextGroupZeroIndex(currentIndex)
	loadImageNodesByGroup(currentIndex)

func _process(delta):
	pass

func loadImageNodesByGroup(startingIndex: int):
	var index = startingIndex
	var currentGroup = dupeData[index]["Group ID"]
	var groupIndices = []
	groupIndices.append(startingIndex)
	while(dupeData[index+1] and dupeData[index+1]["Group ID"] == currentGroup):
		# this should usually only run once
		groupIndices.append(index+1)
		index+=1
	for i in groupIndices:
		createImageNodeByIndex(i)
	pass

func createImageNodeByIndex(index:int):
	var newNode = ImageBlockPacked.instantiate()
	var dict = dupeData[index]
	var imagePath = dict["Folder"] + "/" + dict["Filename"]
	newNode.setImgProperties(imagePath)
	imageBoxNode.addImageNode(newNode)
	# add new node to list
	imageNodes.append(newNode)
	pass

func clearImageNodes():
	for n in imageNodes:
		n.queue_free()
	imageNodes = []
	pass

func getNextGroupZeroIndex(currentIndex: int):
	var index = currentIndex
	# Get the next index that is not a header (plaintext)
	# and is not the current index
	# TODO and at least one image at the index exists
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

func getPrevGroupZeroIndex(currentIndex: int):
	var index = currentIndex
	# Get the next index that is not a header (plaintext)
	# and is not the current index
	# and at least one image at the index exists
	var foundNewIndex:bool = false
	pass

func _on_left_pressed()->void:
	clearImageNodes()
	# set previous group index or null if no other group exists
	if currentIndex == 0 and len(dupeData) > 0:
		currentIndex = len(dupeData)-1
	elif len(dupeData) > 0:
		currentIndex -= 1
	setLabel("%s: %s" % [str(currentIndex), dupeData[currentIndex]])
	pass

func _on_right_pressed()->void:
	clearImageNodes()
	# set next group index or null if no other group exists
	if currentIndex == len(dupeData)-1 and len(dupeData) > 0:
		currentIndex = 0
	elif len(dupeData) > 0:
		currentIndex += 1
	setLabel("%s: %s" % [str(currentIndex), dupeData[currentIndex]])
	pass

func setLabel(str: String)->void:
	labelNode.text = str
	pass
