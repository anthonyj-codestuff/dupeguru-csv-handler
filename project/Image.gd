extends Control
const MODULE_NAME = "Image"
var logger = LogWriter.new()

@onready var textureNode = get_node("Container/TextureRect")
@onready var labelNode = get_node("Container/FilenameLabel")
var imageOptions: ImageOptions

func _ready():
	pass

func _process(delta):
	pass

func setProperties(options:ImageOptions):
	imageOptions = options
	textureNode = get_node("Container/TextureRect")
	labelNode = get_node("Container/FilenameLabel")
	loadImageFile(options.imageFilepath, textureNode)
	labelNode.text = getFilepathByLayers(3)
	pass

func loadImageFile(path: String, node: Node):
	node.texture = Utils.loadImageToTexture(path)

func getFilepathByLayers(layers: int):
	var fileLayers = imageOptions.imageFilepath.split("/")
	if fileLayers.size() > layers:
		print(str(fileLayers.size()-layers))
		print(str(fileLayers.size()))
		return "/".join(fileLayers.slice(fileLayers.size()-layers, fileLayers.size()))
	else:
		return imageOptions.imageFilepath
