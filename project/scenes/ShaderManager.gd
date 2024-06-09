extends Node
const MODULE_NAME = "ShaderManager"
var logger = LogWriter.new()

@onready var diffShader = ShaderMaterial.new()

func _ready():
	diffShader.shader = load("res://assets/diff.gdshader")

func applyShaderToNodeArray(nodes: Array, reference: int = 0):
	if not nodes.size():
		return
	var referenceNode = nodes[reference]
	var imageFile = referenceNode.imageOptions.imageFilepath
	var image_texture = ImageTexture.new()
	if(Utils.fileExistsAtLocation(imageFile)):
		var image = Image.new()
		image.load(imageFile)
		image_texture.set_image(image)
		pass
	for i in nodes.size():
		if i != reference:
			_applyShaderToNode(image_texture, nodes[i], diffShader)
	pass

func removeShadersFromNodeArray(nodes: Array):
	for n in nodes:
		_removeShaderFromNode(n)

func _applyShaderToNode(texture: ImageTexture, node: Control, shader: ShaderMaterial):
	shader.set_shader_parameter("textureB", texture)
	node.setShader(shader)

func _removeShaderFromNode(node: Control):
	node.setShader(null)
