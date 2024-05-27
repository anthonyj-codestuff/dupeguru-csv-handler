extends Control
const MODULE_NAME = "Image"
var logger = LogWriter.new()

@onready var TextureNode
@onready var LabelNode
var imageOptions: ImageOptions

func _ready():
	pass

func _process(delta):
	pass

func setProperties(options:ImageOptions):
	TextureNode = get_node("Container/TextureRect")
	LabelNode = get_node("Container/FilenameLabel")
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
