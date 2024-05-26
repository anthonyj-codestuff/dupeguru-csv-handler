extends Node
 
# this is a work-in-progress Godot 4 script that forces the game window to maintain a constant aspect ratio
# to use it, create a plain Node in the root scene and attach this script to it
# KNOWN ISSUES
# the viewport does not properly update if the window is resized horizontally and vertically at the same time
# the function triggers at least 3-5 times on every resize. Not sure why, but I have not seen it loop forever
 
@onready var defaultSize = DisplayServer.window_get_size()
@onready var previousSize = defaultSize
 
func _ready():
	get_tree().get_root().size_changed.connect(resize_screen)
 
func resize_screen():
	var newSize = DisplayServer.window_get_size()
	var scale = Vector2(newSize) / Vector2(defaultSize)
	# TODO this is probably not a foolproof way of determining which way the window is being scaled
	var scaleUp = newSize > previousSize
	
	if DisplayServer.window_get_position().y < 0:
		DisplayServer.window_set_position(Vector2i(DisplayServer.window_get_position().x, 0))
	
	if newSize != previousSize:
		if not scaleUp and (scale.x < 0.25 or scale.y < 0.25):
			newSize = defaultSize / 4
			previousSize = newSize
			DisplayServer.window_set_size(newSize)
		else:
			if (scaleUp and scale.x >= scale.y) or (not scaleUp and scale.x < scale.y):
				newSize = Vector2i(newSize.x, defaultSize.y * scale.x)
				previousSize = newSize
				DisplayServer.window_set_size(newSize)
			elif (scaleUp and scale.x < scale.y) or (not scaleUp and scale.x >= scale.y):
				newSize = Vector2i(defaultSize.x * scale.y, newSize.y)
				previousSize = newSize
				DisplayServer.window_set_size(newSize)
