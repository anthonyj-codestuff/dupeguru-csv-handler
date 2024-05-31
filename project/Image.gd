extends Control
const MODULE_NAME = "Image"
var logger = LogWriter.new()

@onready var BorderNode
@onready var TextureNode
@onready var FilenameLabelNode
@onready var InfoLabelNode
@onready var ReasonsLabelNode
var imageOptions: ImageOptions
var styleBox: StyleBoxFlat
var autoselectReasons = []

func _ready():
	pass

func _process(delta):
	pass

func setProperties(options:ImageOptions):
	BorderNode = get_node("SelectedBorder")
	TextureNode = get_node("PanelContainer/TextureRect")
	FilenameLabelNode = get_node("PanelContainer/MarginContainer/FilenameLabel")
	InfoLabelNode = get_node("PanelContainer/MarginContainer/HBoxContainer/InfoLabel")
	ReasonsLabelNode = get_node("PanelContainer/MarginContainer/HBoxContainer/ReasonsLabel")
	BorderNode.visible = false
	if not options.initLoadingError:
		imageOptions = options
		loadImageFile(imageOptions.imageFilepath, TextureNode)
		FilenameLabelNode.text = getFilepathByLayers(imageOptions.imageFilepath, 3)
		InfoLabelNode.text = imageOptions.getStatsReadableString()
	else:
		loadImageFile("", TextureNode)
	pass

func loadImageFile(path: String, node: Node):
	node.texture = Utils.loadImageToTexture(path)

func getFilepathByLayers(path: String, layers: int):
	var fileLayers = path.split("/")
	if fileLayers.size() > layers:
		return "/".join(fileLayers.slice(fileLayers.size()-layers, fileLayers.size()))
	else:
		return imageOptions.imageFilepath

func addPotentialDeletionReason(reason: String = ""):
	if reason.length():
		autoselectReasons.append(reason)
		ReasonsLabelNode.text = "\n".join(autoselectReasons)

func select():
	imageOptions.selected = true
	BorderNode.visible = true
	
func deselect():
	imageOptions.selected = false
	BorderNode.visible = false

func _on_image_button_pressed():
	if imageOptions.selected:
		deselect()
	else:
		select()
	pass
