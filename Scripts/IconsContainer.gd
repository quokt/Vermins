extends Control

func center_first_child():
	self.get_child(0).rect_position = self.rect_size / 2
	
func _process(_delta):
	center_first_child()
