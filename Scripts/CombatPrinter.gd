extends Node

var combat_printer

var singleplayer : bool = false

#func _ready():
	#print_new_line([""])
	#combat_printer.bbcode_text = ""

remotesync func r_print(text_array : Array, display_text : String = "") -> void:
	
	combat_printer = get_tree().get_nodes_in_group("combat_printer")[0]
	
	if combat_printer == null or not is_instance_valid(combat_printer):
		#print("combat_printer var is null in " , self.name, " ", str(self))
		return
	
	for variable in text_array:
		display_text += str(variable)
	
	combat_printer.bbcode_text += display_text
	


func print_new_line(text_array : Array):
	
	var display_text : String = "\n"
	
	if not singleplayer:
		rpc("r_print", text_array, display_text)
	else:
		r_print(text_array, display_text)


func print_next(text_array : Array):
	
	var display_text : String = ""
	if not singleplayer:
		rpc("r_print", text_array, display_text)
	else:
		r_print(text_array, display_text)
