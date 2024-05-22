extends MarginContainer

var textureNode: Node

func _ready():
	pass

func _process(delta):
	pass

func setImgProperties(texture_path: String, sizex: int, sizey: int, selected: bool = false):
	textureNode = get_node("Container/TextureRect")
	size = Vector2(sizex, sizey)
	loadImageFile(texture_path, textureNode)
	pass
	
func loadImageFile(path: String, node: Node):
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	node.texture = image_texture
