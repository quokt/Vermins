extends Node
class_name Item

enum APPLY_MODE {START, TURN, CUSTOM}
enum CUSTOM_APPLY {LEVEL, TARGET}

export (APPLY_MODE) var apply_mode
export (CUSTOM_APPLY) var custom_apply

export (String) var item_name
export (String) var display_name

export (Texture) var item_texture

export (String, MULTILINE) var description

export (int, 1, 50, 1) var cost

var singleplayer : bool = false

var target : Actor = null

func _ready():
	if display_name == "":
		display_name = item_name

func _apply_item(_actor : Actor = target, opt_array : Array = []):
	print("func _apply_item is empty : in ", self)
	pass 
	
func on_apply_signal(opt_array : Array = []):
	_apply_item(target, opt_array)

