extends Control
const MODULE_NAME = "Image"
var logger = LogWriter.new()

@onready var BorderNode
@onready var TextureNode
@onready var FilenameLabelNode
@onready var InfoLabelNode
@onready var ReasonsLabelNode
var imageOptions: ImageOptions
var autoselectReasons = []

func setProperties(options:ImageOptions):
	BorderNode = get_node("SelectedBorder")
	TextureNode = get_node("TextureRect")
	FilenameLabelNode = get_node("PanelContainer/MarginContainer/VBoxContainer/FilenameLabel")
	InfoLabelNode = get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/InfoLabel")
	ReasonsLabelNode = get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ReasonsLabel")
	BorderNode.visible = false
	if not options.initLoadingError:
		imageOptions = options
		loadImageFile(imageOptions.imageFilepath, TextureNode)
		FilenameLabelNode.text = Utils.getFilepathByLayers(imageOptions.imageFilepath, 3)
		InfoLabelNode.text = imageOptions.getStatsReadableString()
	else:
		loadImageFile("", TextureNode)

func loadImageFile(path: String, node: Node):
	node.texture = Utils.loadImageToTexture(path)

func addPotentialDeletionReason(reason: String = ""):
	if reason.length():
		autoselectReasons.append(reason)
		ReasonsLabelNode.text = "\n".join(autoselectReasons)

func setShader(shader: ShaderMaterial):
	if shader:
		TextureNode.material = shader
	else:
		TextureNode.material = null

####################################

func _on_image_button_pressed():
	if !imageOptions.selected and imageOptions.fileExists:
		selectFromUser()
	else:
		deselectFromUser()

func selectFromUser():
	selectInternal()
	SignalBus.emit_signal("image_selected", imageOptions.imageFilename)
	
func deselectFromUser():
	deselectInternal()
	SignalBus.emit_signal("image_deselected", imageOptions.imageFilename)

func selectInternal():
	# called directly by ControlPanel
	if imageOptions.fileExists:
		imageOptions.selected = true
		BorderNode.visible = true
	
func deselectInternal():
	# called directly by ControlPanel
	imageOptions.selected = false
	BorderNode.visible = false
