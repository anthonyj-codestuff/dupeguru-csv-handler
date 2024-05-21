# Stores all data and config presets.
extends Node
const MODULE_NAME = "GlobalData"

# Scene Configs --------------------------
#const SPLASH_SCENE_PATH : String = "res://core/ui/splash/splash.tscn"
#const MAIN_SCENE_PATH : String = "res://template/maps/placeholder/placeholder.tscn"
#const TRANSITION_IMAGE_PATH : String = "res://core/ui/transitions/transition_image.tscn"

# Resource & Packages --------------------
var LOADER_WAIT_TIME : float = 0.5
var PACKAGE_ROOT : String = OS.get_executable_path().get_base_dir()
var PACKAGE_PATHS : Array = [ 
	PACKAGE_ROOT.path_join("contents"),
	PACKAGE_ROOT.path_join("patches"),
]

var CSV_ASSET_PATH: String = "res://assets/dupes.csv"
var CSV_FOOTPRINT: PackedStringArray = ["Group ID", "Filename", "Folder", "Size (KB)", "Modification", "Match %"]
var CSV_OPTIONS = {
		"delim": ",",
		"detect_numbers": true,
		"headers": true,
		"force_float": false
	}
var VALID_IMAGE_EXTENSIONS: Array[String] = ["jpg", "jpeg", "png"]
