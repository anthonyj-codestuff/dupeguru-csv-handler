extends Node2D

@onready var progressBarNode = get_node("TextureProgressBar")
@onready var labelNode = get_node("Label")
var secondaryBar = false

func _ready():
	progressBarNode.visible = true
	SignalBus.show_progress_bar.connect(_on_show_progress_bar)
	SignalBus.hide_progress_bar.connect(_on_hide_progress_bar)
	SignalBus.set_progress_bar.connect(_on_set_progress_bar)
	SignalBus.set_secondary_progress_bar.connect(_on_set_secondary_progress_bar)
	# SignalBus.emit_signal("set_progress_bar", 75, true)

func _on_show_progress_bar():
	visible = true
	progressBarNode.texture_progress = load("res://assets/progressbar_progress.png")
	secondaryBar = false

func _on_hide_progress_bar():
	visible = false
	progressBarNode.texture_progress = load("res://assets/progressbar_progress.png")
	secondaryBar = false

func _on_set_secondary_progress_bar():
	secondaryBar = true
	progressBarNode.texture_progress = load("res://assets/progressbar_progress2.png")
	progressBarNode.value = 0

func _on_set_progress_bar(num: int):
	progressBarNode.value = num
	if secondaryBar:
		labelNode.text = "Deleting JSON files [" + str(num) + "%]"
	else:
		labelNode.text = "Deleting Images [" + str(num) + "%]"
