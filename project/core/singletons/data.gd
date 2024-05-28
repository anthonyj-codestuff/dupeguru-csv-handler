# Stores all data and config presets.
extends Node
const MODULE_NAME = "GlobalData"
var logger = LogWriter.new()

# Resource & Packages --------------------
var LOADER_WAIT_TIME : float = 0.5
var PACKAGE_ROOT : String = OS.get_executable_path().get_base_dir()
var PACKAGE_PATHS : Array = [ 
	PACKAGE_ROOT.path_join("contents"),
	PACKAGE_ROOT.path_join("patches"),
]

var EXTERNAL_ASSETS_FOLDER: String = "../external_assets"
var CSV_FILE_PATH: String = "../external_assets/dupes2.csv"
var CSV_FOOTPRINT_MVP: Array[String] = ["Group ID", "Filename", "Folder"]
var CSV_HEADER_OPTIONS: Array[String] = ["Group ID", "Filename", "Folder", "Size (KB)", "Dimensions", "Modification","Match %"]
var CSV_OPTIONS = {
		"delim": ",",
		"detect_numbers": true,
		"headers": true,
		"force_float": false
	}
var VALID_IMAGE_EXTENSIONS: Array[String] = ["jpg", "jpeg", "png"]
