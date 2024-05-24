extends Control
const MODULE_NAME = "Image"

var textureNode

func _ready():
	pass

func _process(delta):
	pass

func setImgProperties(texture_path: String, selected: bool = false):
	textureNode = get_node("Container/TextureRect")
	loadImageFile(texture_path, textureNode)
	pass

func loadImageFile(path: String, node: Node):
	# TODO check if image exists and load placeholder image if it does not
	node.texture = Utils.loadImageToTexture(path)
