extends Node
const MODULE_NAME = "PythonManager"
var logger = LogWriter.new()

const pyScript = "./assets/GetFileProperties.py"
var pythonEnabled = false
var command

func _ready():
	logger.info("Checking system for Python installation...", MODULE_NAME)
	var version = OS.execute("python", ["--version"], [])
	var version3 = OS.execute("python3", ["--version"], [])
	if version3 == 0:
		logger.info("Python3 detected. Enabling extended functionality", MODULE_NAME)
		pythonEnabled = true
		command = "python3"
	elif version == 0:
		logger.info("Python detected. Enabling extended functionality", MODULE_NAME)
		pythonEnabled = true
		command = "python"
	else:
		logger.info("Python not detected. Extended functionality not enabled", MODULE_NAME)
		


func getFileProperties(filename)->Dictionary:
	if pythonEnabled:
		var pystdout = []
		var args = [pyScript, filename]
		var result = OS.execute(command, args, pystdout)

		if result == 0:
			return JSON.parse_string(pystdout[0])
	return {}
