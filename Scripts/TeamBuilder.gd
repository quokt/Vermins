extends PanelContainer


export(String, FILE, "*.json") var char_file_path : String 
const CHARACTERS = []

onready var actor_icon = preload("res://Scenes/ActorIcon.tscn")

onready var char_list_node = $VBoxContainer/HBoxContainer/MarginContainer2/TabContainer/Characters/HBoxContainer/MarginContainer/ItemList

onready var current_char_node = $VBoxContainer/HBoxContainer/MarginContainer2/TabContainer/Characters/HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/CurrentSelection
onready var current_char_label = $VBoxContainer/HBoxContainer/MarginContainer2/TabContainer/Characters/HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/Label


func _ready():
	var characters_list = load_char_list(char_file_path)
	
	
	for character in characters_list:
		
		var instance = actor_icon.instance()
		instance.set_character(character)
		char_list_node.add_child(instance)
		instance.connect("pressed", self, "on_char_pressed", [character])



func on_char_pressed(character):
	print(character, " pressed")
	

func load_char_list(file_path) -> Dictionary:
	var file = File.new()
	
	file.open(file_path, file.READ)
	var char_list = parse_json(file.get_as_text())
	return char_list
	
