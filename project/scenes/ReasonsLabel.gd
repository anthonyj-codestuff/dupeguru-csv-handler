extends Label

func _process(delta):
	if self.text == "":
		self.visible = false
	else:
		self.visible  = true
