extends Button

func _ready():
	pass


func _on_pressed():
	var filename = "../external_assets/0.jpeg"
	var command = "python3"
	var pystdout = []
#	var args = ["./assets/GetFileProperties.py", filename]
	var args = ["./assets/echo.py", filename]
	var result = OS.execute(command, args, pystdout)

	if result == 0:
		for i in pystdout:
			print("pyout  "+ str(pystdout))
		
	print("result "+ str(result))
	pass
