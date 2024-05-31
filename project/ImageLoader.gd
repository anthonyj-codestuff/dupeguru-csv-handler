extends Control
const MODULE_NAME = "ImageLoader"
var logger = LogWriter.new()
var ImageScenePacked = preload("res://Image.tscn")

# define important reference nodes
@onready var imageBoxNode = get_node("ImageBox")
@onready var python = get_node("PythonManager")
@onready var selector = get_node("AutoSelector")
# data from csv file
var dupeData = []
# storage for generated nodes
var imageNodes = []
# Indicates the 0th index of the current group
# if on group 2 of [0,0,1,1,2,2,3,3,3], index should be 4
var currentIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	dupeData = Utils.importCSV(Data.CSV_FILE_PATH, Data.CSV_OPTIONS)
	var headers: Array = Array(dupeData[0]) if dupeData else []
	# if the CSV file does not have the absolutely necessary keys,
	# post an error message and delete the loaded CSV data
	if not Data.CSV_FOOTPRINT_MVP.all(func(key): return headers.has(key)):
		var errLabelNode = get_node("Node2D/ErrorLabel")
		var missingKeys = Data.CSV_FOOTPRINT_MVP.filter(func(key): return not headers.has(key))
		var missingKeysStr = ", ".join(missingKeys)
		errLabelNode.text = "CSV file not found or does not have expected minimum footprint. Missing keys [%s]" % missingKeysStr
		dupeData = []
	# Remove CSV header, it will only get in the way
	dupeData.pop_front()
	loadImageNodeGroupByStartingIndex(currentIndex)
	selector.autoSelectNodes(imageNodes)

func _process(delta):
	pass

func getIndexListForGroupId(id: int):
	var list = []
	for i in range(dupeData.size()):
		if dupeData[i]["Group ID"] == id:
			list.append(i)
	return list

func fileExistsForIndex(id: int):
	var dict = dupeData[id]
	var filepath = dict["Folder"].path_join(dict["Filename"])
	return Utils.fileExistsAtLocation(filepath)

func loadImageNodeGroupByStartingIndex(startingIndex: int):
	if not dupeData.size():
		return
	var index = startingIndex
	var currentGroup = dupeData[index]["Group ID"]
	var groupIndices = []
	groupIndices.append(startingIndex)
	while(index+1 < dupeData.size() and dupeData[index+1]["Group ID"] == currentGroup):
		# this should usually only run once
		groupIndices.append(index+1)
		index+=1
	for i in groupIndices:
		createImageNodeByIndex(i)
	pass

func createImageNodeByIndex(index:int):
	var options = ImageOptions.new(index, dupeData[index], python)
	var newNode = ImageScenePacked.instantiate()
	newNode.setProperties(options)
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
	if not dupeData.size():
		return
	var currentGroup = dupeData[currentIndex]["Group ID"]
	var index = currentIndex + 1
	var foundNewIndex:bool = false
	while not foundNewIndex and index != currentIndex:
		if len(dupeData)-1 < index:
			index = 0
		if dupeData[index]["Group ID"] != currentGroup:
			var groupIndexList = getIndexListForGroupId(dupeData[index]["Group ID"])
			if groupIndexList.any(func(i): return fileExistsForIndex(i)):
				# if there is any file that exists for this group, accept it
				foundNewIndex = true
				break
		index += 1
	if foundNewIndex:
		return index
	else:
		# this will happen if there is only one valid group in dupedata
		return null

func getPrevGroupZeroIndex(currentIndex: int):
	if not dupeData.size():
		return
	var currentGroup = dupeData[currentIndex]["Group ID"]
	var index = currentIndex - 1
	var foundNewIndex:bool = false
	while not foundNewIndex and index != currentIndex:
		if 0 > index:
			index = dupeData.size() - 1
		var thisGroupId = dupeData[index]["Group ID"]
		var beforeThisGroupId = dupeData[index-1]["Group ID"] if index>0 else dupeData[-1]["Group ID"]
		# we have reached the correct index if it has a different group and it is the earliest instance of that group
		if thisGroupId != currentGroup and thisGroupId != beforeThisGroupId:
			var groupIndexList = getIndexListForGroupId(dupeData[index]["Group ID"])
			if groupIndexList.any(func(i): return fileExistsForIndex(i)):
				# if there is any file that exists for this group, accept it
				foundNewIndex = true
				break
		index -= 1
	if foundNewIndex:
		return index
	else:
		# this will happen if there is only one valid group in dupedata
		return null

func _on_left_pressed()->void:
	clearImageNodes()
	if not dupeData.size():
		return
	# set previous group index or null if no other group exists
	currentIndex = getPrevGroupZeroIndex(currentIndex)
	if currentIndex != null:
		loadImageNodeGroupByStartingIndex(currentIndex)
		selector.autoSelectNodes(imageNodes)
	pass

func _on_right_pressed()->void:
	clearImageNodes()
	if not dupeData.size():
		return
	# set next group index or null if no other group exists
	currentIndex = getNextGroupZeroIndex(currentIndex)
	if currentIndex != null:
		loadImageNodeGroupByStartingIndex(currentIndex)
		selector.autoSelectNodes(imageNodes)
	pass


func _on_select_all_pressed():
	for node in imageNodes:
		node.select()
	pass # Replace with function body.


func _on_deselect_pressed():
	for node in imageNodes:
		node.deselect()
	pass # Replace with function body.
