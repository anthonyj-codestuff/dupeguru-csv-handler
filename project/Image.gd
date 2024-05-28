extends Control
const MODULE_NAME = "Image"
var logger = LogWriter.new()

@onready var BorderNode
@onready var TextureNode
@onready var LabelNode
var imageOptions: ImageOptions
var styleBox: StyleBoxFlat

func _ready():
	pass

func _process(delta):
	pass

func setProperties(options:ImageOptions):
	BorderNode = get_node("SelectedBorder")
	TextureNode = get_node("PanelContainer/TextureRect")
	LabelNode = get_node("PanelContainer/MarginContainer/FilenameLabel")
	BorderNode.visible = false
	if not options.initLoadingError:
		imageOptions = options
		loadImageFile(imageOptions.imageFilepath, TextureNode)
		LabelNode.text = getFilepathByLayers(imageOptions.imageFilepath, 3)
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

func _on_image_button_pressed():
	if imageOptions.selected:
		imageOptions.selected = false
		BorderNode.visible = false
	else:
		imageOptions.selected = true
		BorderNode.visible = true
	pass
