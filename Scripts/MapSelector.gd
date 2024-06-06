extends Control

signal map_selected() #signal used by lobby to start multiplayer game

const MAPS_PATH = "res://Data/Maps.tres"

var selected_map : String

onready var maps_list_node = $VBoxContainer/ScrollContainer/VBoxContainer

var map_button_min_size = Vector2(0, 80)

var disabled : bool = false

var excluded = [
	"default", "funtain", "lava", "new", "rocks", "test"
]


func _ready() -> void:
	for map in load_maps_list():
		
		if str(map) in excluded:
			continue
		var new_button = Button.new()
		new_button.rect_min_size = map_button_min_size
		new_button.text = str(map)
		
		
		maps_list_node.add_child(new_button)
		
		new_button.connect("pressed", self, "on_button_pressed", [new_button.text])


func load_maps_list() -> Dictionary:
	
	var dictionary  := {}
	
	var resource = ResourceLoader.load(MAPS_PATH)
	dictionary = resource.maps.duplicate(true)
	
	return dictionary


func on_button_pressed(text : String) -> void:
	selected_map = text
	print(selected_map)
	emit_signal("map_selected")
