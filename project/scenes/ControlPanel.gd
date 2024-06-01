extends Control

signal select_all_pressed()
signal select_none_pressed()
signal left_pressed()
signal right_pressed()
signal commit_pressed()
signal undo_pressed()
signal delete_pressed()

func _on_select_all_pressed():
	emit_signal("select_all_pressed")

func _on_deselect_pressed():
	emit_signal("select_none_pressed")

func _on_left_pressed():
	emit_signal("left_pressed")

func _on_right_pressed():
	emit_signal("right_pressed")

func _on_commit_pressed():
	emit_signal("commit_pressed")

func _on_undo_pressed():
	emit_signal("undo_pressed")

func _on_delete_pressed():
	emit_signal("delete_pressed")
