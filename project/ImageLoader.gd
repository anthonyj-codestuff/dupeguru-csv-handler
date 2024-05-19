extends Node2D

const path = "/Users/anthonyjett/Documents/Godot/My Projects/240429-Dupe CSV Handler/external_assets"
var images = []
var extensions: Array[String] = ["jpg", "jpeg", "png"]
var options = {
		"delim": ",",
		"detect_numbers": true,
		"headers": true,
		"force_float": false
	}
var index = 0
var hBoxNode
var labelNode

# Called when the node enters the scene tree for the first time.
func _ready():
	labelNode = get_node("Label")
	hBoxNode = get_node("HBox")
	var dupeData = Utils.importCSV(Data.CSV_ASSET_PATH, options)
	if dupeData[0] != Data.CSV_FOOTPRINT:
		printerr("File does not match expected footprint")
		return
	hBoxNode.size.x = get_viewport().get_visible_rect().size.x
	hBoxNode.size.y = get_viewport().get_visible_rect().size.y

func loadImageNodesByGroup(index: int):
	pass

func loadImageFile(path: String, node: Node):
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	node.texture = image_texture

func loadImageGroup():
	pass

func _on_left_pressed()->void:
	if index == 0 and len(images) > 0:
		index = len(images)-1
	elif len(images) > 0:
		index -= 1
	setLabel("%s: %s" % [str(index), images[index]])
	pass

func _on_right_pressed()->void:
	if index == len(images)-1 and len(images) > 0:
		index = 0
	elif len(images) > 0:
		index += 1
	setLabel("%s: %s" % [str(index), images[index]])
	pass

func setLabel(str: String)->void:
	labelNode.text = str
	pass
