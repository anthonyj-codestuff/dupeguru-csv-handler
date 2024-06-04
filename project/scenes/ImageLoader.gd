extends Control
const MODULE_NAME = "ImageLoader"
var logger = LogWriter.new()
var ImageScenePacked = preload("res://scenes/Image.tscn")

# define important reference nodes
@onready var imageBoxNode = get_node("ImageBox")
@onready var python = get_node("PythonManager")
@onready var selector = get_node("AutoSelector")
@onready var noImagesNode = get_node("TextureNoImages")
# data from csv file
var dupeData = []
# storage for generated nodes (currently displayed)
var imageNodes = []
# storage for committed image indices
var committedImages = []
# Indicates the 0th index of the current group
# if on group 2 of [0,0,1,1,2,2,3,3,3], index should be 4
var currentIndex = 0

func _ready():
	# register signals from control panel
	SignalBus.select_all_pressed.connect(_on_control_panel_select_all_pressed)
	SignalBus.select_none_pressed.connect(_on_control_panel_select_none_pressed)
	SignalBus.left_pressed.connect(_on_control_panel_left_pressed)
	SignalBus.right_pressed.connect(_on_control_panel_right_pressed)
	SignalBus.commit_pressed.connect(_on_control_panel_commit_pressed)
	SignalBus.undo_pressed.connect(_on_control_panel_undo_pressed)
	SignalBus.delete_pressed.connect(_on_control_panel_delete_pressed)
	# import CSV data
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
	# set initial commit button state
	# TODO this doesn't work for some reason
	if someImagesAreSelected():
		SignalBus.emit_signal("some_images_selected")
	else:
		SignalBus.emit_signal("no_images_selected")

func getIndexListForGroupId(id: int)->Array[int]:
	var list: Array[int] = []
	for i in range(dupeData.size()):
		if dupeData[i]["Group ID"] == id:
			list.append(i)
	return list

func groupIndexListIsValid(ids: Array[int])->bool:
	# a list of indices is valid for display if
	# all ids belong to the same group
	# at least two images that exist have not been committed
	if not ids.size():
		return false

	var group = dupeData[ids[0]]["Group ID"]
	if not group and not group == 0:
		return false

	var sameGroup = ids.all(func(i): return dupeData[i]["Group ID"] == group)
	if not sameGroup:
		return false

	var validImageCount = 0
	for i in ids:
		if not committedImages.has(i) and fileExistsForIndex(i):
			validImageCount += 1
	return validImageCount > 1

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

func createImageNodeByIndex(index:int):
	var options = ImageOptions.new(index, dupeData[index], python)
	var newNode = ImageScenePacked.instantiate()
	newNode.setProperties(options)
	imageBoxNode.addImageNode(newNode)
	# add new node to list
	imageNodes.append(newNode)

func clearImageNodes():
	for n in imageNodes:
		n.queue_free()
	imageNodes = []

func someImagesAreSelected()->bool:
	return imageNodes.any(func(node): return node.imageOptions.selected == true)

func getNextGroupZeroIndex(currentIndex: int):
	if not dupeData.size():
		return null
	var currentGroup = dupeData[currentIndex]["Group ID"]
	var index = currentIndex + 1
	var foundNewIndex:bool = false
	while not foundNewIndex and index != currentIndex:
		if index >= len(dupeData):
			index = 0
			if index == currentIndex: #edge case for if currentIndex is 0
				break
		var group = dupeData[index]["Group ID"]
		if group != currentGroup:
			var groupIndexList = getIndexListForGroupId(group)
			if groupIndexListIsValid(groupIndexList):
				foundNewIndex = true
			else:
				index += groupIndexList.size()
		else:
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
		if index < 0:
			index = dupeData.size() - 1
		var thisGroupId = dupeData[index]["Group ID"]
		var beforeThisGroupId = dupeData[index-1]["Group ID"] if index>0 else dupeData[-1]["Group ID"]
		# we have reached the correct index if it has a different group and it is the earliest instance of that group
		if thisGroupId != currentGroup and thisGroupId != beforeThisGroupId:
			var groupIndexList = getIndexListForGroupId(thisGroupId)
			if groupIndexListIsValid(groupIndexList):
				foundNewIndex = true
				break
		index -= 1
	if foundNewIndex:
		return index
	else:
		# this will happen if there is only one valid group in dupedata
		return null

func updateCommitCount():
	if committedImages.size():
		SignalBus.some_deletes_committed.emit(committedImages.size())
	else:
		SignalBus.no_deletes_committed.emit()

####################################

func _on_control_panel_select_all_pressed():
	for node in imageNodes:
		node.selectInternal()
	SignalBus.emit_signal("some_images_selected")

func _on_control_panel_select_none_pressed():
	for node in imageNodes:
		node.deselectInternal()
	SignalBus.emit_signal("no_images_selected")

func _on_control_panel_left_pressed()->void:
	clearImageNodes()
	if not dupeData.size():
		return
	# set previous group index or null if no other group exists
	currentIndex = getPrevGroupZeroIndex(currentIndex)
	if currentIndex != null:
		loadImageNodeGroupByStartingIndex(currentIndex)
		selector.autoSelectNodes(imageNodes)
		if someImagesAreSelected():
			SignalBus.emit_signal("some_images_selected")
		else:
			SignalBus.emit_signal("no_images_selected")
	else:
		noImagesNode.visible = true
		SignalBus.emit_signal("no_images_selected")

func _on_control_panel_right_pressed()->void:
	clearImageNodes()
	if not dupeData.size():
		return
	# set next group index or null if no other group exists
	currentIndex = getNextGroupZeroIndex(currentIndex)
	if currentIndex != null:
		loadImageNodeGroupByStartingIndex(currentIndex)
		selector.autoSelectNodes(imageNodes)
		if someImagesAreSelected():
			SignalBus.emit_signal("some_images_selected")
		else:
			SignalBus.emit_signal("no_images_selected")
	else:
		noImagesNode.visible = true
		SignalBus.emit_signal("no_images_selected")

func _on_control_panel_commit_pressed():
	# add all selected images to commit list, remove nodes from tree
	for i in range(imageNodes.size()-1,-1,-1):
		if imageNodes[i].imageOptions.selected:
			logger.info("committing [%s]" % imageNodes[i].imageOptions.imageFilename, MODULE_NAME)
			committedImages.append(imageNodes[i].imageOptions.dictIndex)
			imageNodes.pop_at(i).queue_free()
	updateCommitCount()
	if imageNodes.filter(func(n): return n.imageOptions.fileExists).size() < 2:
		# if the remaining nodes have 1 or 0 images remaining, move on to the next group
		_on_control_panel_right_pressed()

func _on_control_panel_undo_pressed():
	logger.info("Hit function for undo", MODULE_NAME)

func _on_control_panel_delete_pressed():
	logger.info("Hit function for delete", MODULE_NAME)
