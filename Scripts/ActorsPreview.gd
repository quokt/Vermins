extends Container

const DIRECTIONS = [Vector2(-1,1), Vector2(1, 1), Vector2(1,-1), Vector2(-1, -1)]
var distance := Vector2(50, 45)
var offset := Vector2(-30, -50)

#func _process(_delta):
#	place_characters()


func place_characters():
	self.rect_size = get_parent().rect_size
	var middle_pos = rect_size/2
	
#	var i : int = 0
#	for child in get_children():
#		match i:
#			0: child.rect_position = middle_pos + offset
#			_: child.rect_position = (middle_pos + DIRECTIONS[i-1] * distance) + offset
#		i += 1
	var i : int = 0
	for child in $YSort.get_children():
		match i:
			0: child.rect_position = middle_pos + offset
			_: child.rect_position = (middle_pos + DIRECTIONS[i-1] * distance) + offset
		i += 1


func _on_ActorsPreview_sort_children():
	place_characters()
