extends Node2D

var textureNode: Node
var marginNode: Node

func _ready():
	pass

func _process(delta):
	pass

func setImgProperties(texture_path: String, sizex: int, sizey: int, selected: bool = false):
	textureNode = get_node("MarginContainer/Container/TextureRect")
	marginNode = get_node("MarginContainer")
	marginNode.size.x = sizex
	marginNode.size.y = sizey
	loadImageFile(texture_path, textureNode)
	pass
	
func loadImageFile(path: String, node: Node):
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	node.texture = image_texture
