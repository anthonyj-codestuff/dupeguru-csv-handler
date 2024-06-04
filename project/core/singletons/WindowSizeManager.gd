extends Node
const MODULE_NAME = "WindowSizeManager"
var logger = LogWriter.new()
 
# this is a work-in-progress Godot 4 script that forces the game window to maintain a constant aspect ratio
# to use it, create a plain Node in the root scene and attach this script to it
# KNOWN ISSUES
# the viewport does not properly update if the window is resized horizontally and vertically at the same time
# the function triggers at least 3-5 times on every resize. Not sure why, but I have not seen it loop forever
 
@onready var defaultSize = DisplayServer.window_get_size()
@onready var previousSize = defaultSize
var min_window_size = Vector2(640,360) # The minimum window resolution you want. 

func _ready():
	#get_tree().get_root().size_changed.connect(resize_screen) # Disabling the resize code here, feel free to delete if no longer needed.
	DisplayServer.window_set_min_size(min_window_size)
