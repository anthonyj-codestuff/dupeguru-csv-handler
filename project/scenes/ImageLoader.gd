extends Control
const MODULE_NAME = "ImageLoader"
var logger = LogWriter.new()
var ImageScenePacked = preload("res://scenes/Image.tscn")

@onready var imageBoxNode = get_node("ImageBox")
@onready var python = get_node("PythonManager")
@onready var selector = get_node("AutoSelector")
@onready var noImagesNode = get_node("TextureNoImages")
@onready var errLabelNode = get_node("ErrorLabel")
# data from csv file
var dupeData = []
# storage for generated nodes (currently displayed)
var imageNodes = []
# storage for committed image indices
var committedImages = []
# Indicates the 0th index of the current group
# if on group 2 of [0,0,1,1,2,2,3,3,3], index should be 4
var currentIndex: int = 0

const NEXT = true
const PREV = false

func _ready():
	# register signals from control panel
	SignalBus.select_all_pressed.connect(_on_control_panel_select_all_pressed)
	SignalBus.select_none_pressed.connect(_on_control_panel_select_none_pressed)
	SignalBus.left_pressed.connect(_on_control_panel_left_pressed)
	SignalBus.right_pressed.connect(_on_control_panel_right_pressed)
	SignalBus.commit_pressed.connect(_on_control_panel_commit_pressed)
	SignalBus.undo_pressed.connect(_on_control_panel_undo_pressed)
	SignalBus.delete_confirmed.connect(_on_user_delete_confirmed)
	# import CSV data
	dupeData = Utils.importCSV(Data.CSV_FILE_PATH, Data.CSV_OPTIONS, errLabelNode)
	changeScene(NEXT)

# Master function manages everything else
func changeScene(ascending:bool = true, inclusive: bool = true):
	if ascending:
		# set index to next 0th place or -1 if no valid index exists
		currentIndex = getNextValidGroupZeroIndex(currentIndex, inclusive)
	else:
		currentIndex = getPrevValidGroupZeroIndex(currentIndex)
	
	if currentIndex < 0:
		clearImageNodes()
		setNoImagesIndicatorVisible(true)
		updateControlPanelButtons()
	else:
		# currentIndex is at the 0th index of a valid group
		clearImageNodes()
		setNoImagesIndicatorVisible(false)
		loadNodeGroupFromIndex(currentIndex)
		runAutoselectorOnCurrentScene()
		updateControlPanelButtons()

# # # # # #
# UTILITY

func fileExistsForIndex(id: int)->bool:
	var dict = dupeData[id]
	var filepath = dict["Folder"].path_join(dict["Filename"])
	return Utils.fileExistsAtLocation(filepath)

func someImagesAreSelected()->bool:
	###/*
	# simply returns true if there is at least one image with selected: true
	###*/
	return imageNodes.any(func(node): return node.imageOptions.selected == true)

func groupIndexListIsValid(ids: Array[int])->bool:
	###/*
	# a list of indices is valid for display if
	# - all ids belong to the same group
	# - at least two images that exist have not been committed
	###*/
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

func getIndexListForGroupId(id: int, startingIndex: int = 0)->Array[int]:
	# peace of mind check. Doesn't really do anything, but might alert dev to weird behavior
	if dupeData[id-1]["Group ID"] == id:
		logger.warn("Getting index list using non-0th index [%s] for group [%s]" % [startingIndex, id], MODULE_NAME)
	var list: Array[int] = []
	for i in range(startingIndex, dupeData.size()):
		if dupeData[i]["Group ID"] == id:
			list.append(i)
	return list

# # # # # # #
# MAIN FUNCS

func loadNodeGroupFromIndex(startingIndex: int):
	###/*
	# creates uncomitted image nodes from the starting index's group
	# aassumes that the starting index is the 0th index for the group
	# also assumes that the group is valid for display
	###*/
	if not dupeData.size():
		logger.warn("received request to load from no data", MODULE_NAME)
		return
	var index = startingIndex
	var currentGroup = dupeData[index]["Group ID"]
	var groupIndices = getIndexListForGroupId(currentGroup, startingIndex)
	for i in groupIndices:
		if not committedImages.has(i):
			createImageNodeByIndex(i)

func createImageNodeByIndex(index:int)->void:
	###/*
	# creates a new image nodes using the data at index
	# assumes that the data is eligible for display
	###*/
	var options = ImageOptions.new(index, dupeData[index], python)
	var newNode = ImageScenePacked.instantiate()
	newNode.setProperties(options)
	imageBoxNode.addImageNode(newNode)
	# add new node to list
	imageNodes.append(newNode)

func getNextValidGroupZeroIndex(startingIndex: int, inclusive: bool)->int:
	###/*
	# takes in an int representing the 0th instance of a group
	# outputs the 0th index of the next group that meets display requirements
	# if inclusive = true, it will check if the current
	# group is still valid before moving on
	# outputs -1 if there is no valid group
	###*/
	var index = startingIndex
	var startingGroupId = dupeData[index]["Group ID"]
	var foundNextGroup = false
	if inclusive:
		var startingGroup = getIndexListForGroupId(startingGroupId, index)
		if groupIndexListIsValid(startingGroup):
			foundNextGroup = true
	
	while not foundNextGroup:
		index = getNextGroupZeroIndex(index)
		if index < 0:
			index = -1
			break
		var nextGroupId = dupeData[index]["Group ID"]
		var nextGroup = getIndexListForGroupId(nextGroupId, index)
		if groupIndexListIsValid(nextGroup):
			# this will return the starting index if it is the last valid group
			foundNextGroup = true
		elif nextGroupId == startingGroupId:
			# if we have traversed the entire list and not found a valid group, quit
			index = -1
			break
	return index

func getPrevValidGroupZeroIndex(startingIndex)->int:
	###/*
	# takes in an int representing the 0th instance of a group
	# outputs the 0th index of the previous group that meets display requirements
	# outputs -1 if there is no valid group
	###*/
	var index = startingIndex
	var startingGroupId = dupeData[index]["Group ID"]
	var foundPrevGroup = false
	
	while not foundPrevGroup:
		index = getPrevGroupZeroIndex(index)
		if index < 0:
			index = -1
			break
		var prevGroupId = dupeData[index]["Group ID"]
		var prevGroup = getIndexListForGroupId(prevGroupId, index)
		if groupIndexListIsValid(prevGroup):
			# this will return the starting index if it is the last valid group
			foundPrevGroup = true
		elif prevGroupId == startingGroupId:
			# if we have traversed the entire list and not found a valid group, quit
			index = -1
			break
	return index

func getNextGroupZeroIndex(startingIndex: int)->int:
	###/*
	# takes in an int representing the 0th instance of a group
	# outputs the 0th index of the N+1 group
	# outputs -1 if there is no N+1 group
	# Does not check if group is valid for display
	###*/
	if not dupeData.size() > 1:
		return -1
	var startingGroup = dupeData[startingIndex]["Group ID"]
	var index = startingIndex + 1
	var foundNewIndex:bool = false
	while not foundNewIndex and index != startingIndex:
		if index >= len(dupeData):
			index = 0
			if index == startingIndex: #if startingIndex is 0
				break
		var group = dupeData[index]["Group ID"]
		if group != startingGroup:
				foundNewIndex = true
		else:
			index += 1
	if foundNewIndex:
		return index
	else:
		return -1

func getPrevGroupZeroIndex(startingIndex: int)->int:
	###/*
	# takes in an int representing the 0th instance of a group
	# outputs the 0th index of the N-1 group
	# outputs -1 if there is no N-1 group
	# Does not check if group is valid for display
	###*/
	if not dupeData.size() > 1:
		return -1
	var startingGroup = dupeData[startingIndex]["Group ID"]
	var index = startingIndex - 1
	var foundNewIndex:bool = false
	while not foundNewIndex and index != startingIndex:
		if index < 0:
			index = dupeData.size() - 1
		var group = dupeData[index]["Group ID"]
		var prevGroup = dupeData[index-1]["Group ID"] if index>0 else dupeData[-1]["Group ID"]
		# we have reached the correct index if it has a different group and it is the earliest instance of that group
		if group != startingGroup and group != prevGroup:
			foundNewIndex = true
		else:
			index -= 1
	if foundNewIndex:
		return index
	else:
		return -1

func runAutoselectorOnCurrentScene()->void:
	selector.autoSelectNodes(imageNodes)

func clearImageNodes()->void:
	for n in imageNodes:
		n.queue_free()
	imageNodes = []

# # # # # # # #
# UI Functions

func updateCommitLabels()->void:
	###/*
	# this function sends a signal to update UI elements
	# if the user has added images to the commit queue,
	# checks how many recent commits are from the same group
	# UI elements get the undo count and the total commit count
	###*/
	if committedImages.size():
		var committedCount = committedImages.size()
		var lastUndoGroup = dupeData[committedImages[-1]]["Group ID"]
		var lastUndoCount = 0
		for i in range(committedImages.size()-1,-1,-1):
			var group = dupeData[committedImages[i]]["Group ID"]
			if group == lastUndoGroup:
				lastUndoCount += 1
			else:
				break
		SignalBus.some_deletes_committed.emit(committedCount, lastUndoCount)
	else:
		SignalBus.no_deletes_committed.emit()

func setNoImagesIndicatorVisible(setVisible: bool = false):
	noImagesNode.visible = setVisible

func updateControlPanelButtons()->void:
	if someImagesAreSelected():
		SignalBus.emit_signal("some_images_selected")
	else:
		SignalBus.emit_signal("no_images_selected")

# # # # # # # # # #
# OUTGOING SIGNALS

# TODO Consider disabling control panel buttons if there are no images available
func _on_control_panel_select_all_pressed():
	for node in imageNodes:
		node.selectInternal()
	SignalBus.emit_signal("some_images_selected")

func _on_control_panel_select_none_pressed():
	for node in imageNodes:
		node.deselectInternal()
	SignalBus.emit_signal("no_images_selected")

func _on_control_panel_left_pressed()->void:
	changeScene(PREV)

func _on_control_panel_right_pressed()->void:
	# passing inclusive: false forces the scene to move on from a valid group
	changeScene(NEXT, false)

func _on_control_panel_commit_pressed():
	# add all selected images to commit list, remove nodes from tree
	for i in range(imageNodes.size()-1,-1,-1):
		if imageNodes[i].imageOptions.selected:
			logger.info("committing [%s]" % imageNodes[i].imageOptions.imageFilename, MODULE_NAME)
			committedImages.append(imageNodes[i].imageOptions.dictIndex)
	updateCommitLabels()
	# this may or may not move on to the next group if there is still a valid group here
	changeScene(NEXT)

func _on_control_panel_undo_pressed():
	# uncommit all consectutive images of the last committed group
	if committedImages.size():
		var lastImageIndex = committedImages[-1]
		var groupToUncommit = dupeData[lastImageIndex]["Group ID"]
		var uncommitMore = true
		while uncommitMore and committedImages.size():
			lastImageIndex = committedImages[-1]
			var groupId = dupeData[lastImageIndex]["Group ID"]
			if groupId != groupToUncommit:
				uncommitMore = false
			else:
				committedImages.pop_back()
		# after uncomitting, load the uncomitted group and re-auto-select
		# TODO This could be very expensive with large dupe lists
		# Consider iterating backwards from the last index to find the 0
		var uncomittedGroup = getIndexListForGroupId(groupToUncommit)
		currentIndex = uncomittedGroup[0]
		changeScene()

func _on_user_delete_confirmed():
	# on delete, there may or may not be images remaining
	# if user deletes everything, no problem, but if they write to a file,
	# make sure to reset their view instead of leaving them on the blank screen
	if currentIndex == -1:
		currentIndex = 0
	committedImages = []
	updateCommitLabels()
	changeScene(NEXT)
