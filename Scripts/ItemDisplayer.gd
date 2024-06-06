extends Control

signal item_pressed(item)

const SAVE_PATH = "user://game_data.tres"

const ITEMS_RES_PATH = "res://Data/Items.tres"

const ITEMS_BASE_PATH = "res://Items/"

const ITEM_ICON_SCENE = preload("res://Scenes/ItemIcon.tscn")

const TABS = [0, 1, 2, 3, 4]
const InactiveText = ["Fru", "Veg", "Dri", "Junk", "Gold"]
const ActiveText = ["fruits", "veggies", "drinks", "junk", "gold"]

onready var items_node : Node = $Items

onready var tabs_dict : Dictionary = {
	"fruits" : $TabContainer/Fruits/ScrollContainer/GridContainer ,
	"veggies" : $TabContainer/Veggies/ScrollContainer/GridContainer ,
	"drinks" : $TabContainer/Drinks/ScrollContainer/GridContainer ,
	"junk" : $TabContainer/Junk/ScrollContainer/GridContainer ,
	"gold" : $TabContainer/Gold/ScrollContainer/GridContainer
}

onready var tab_container : TabContainer = $TabContainer

var items : Dictionary = {}

func _ready():
	tab_container.connect("tab_selected", self, "on_tab_selected")
	on_tab_selected(0)
	
	add_items()


func on_icon_pressed(item : Item) -> void:
	emit_signal("item_pressed", item)


func add_items() -> void:
	
	var items_res = ResourceLoader.load(ITEMS_RES_PATH)
	var items_unlock = ResourceLoader.load(SAVE_PATH).items_unlock
	#var items_dict : Dictionary = items_res.items_list.duplicate(true)
	
	var i : int = 0
	for container_name in tabs_dict.keys():
		var items_list = items_res.get(container_name)
		for item_name in items_list:
			var item : Item = add_item(item_name)
			if item == null or not is_instance_valid(item):
				print("Ignoring item : " , item_name)
				continue
			
			var container = tabs_dict[container_name]
			var icon = ITEM_ICON_SCENE.instance()
			icon.set_item(item)
			container.add_child(icon)
			icon.connect("pressed", self, "on_icon_pressed", [icon.item])
		
		var unlocked = items_unlock[container_name] if items_unlock.has(container_name) else true
		tab_container.set_tab_disabled(i, not unlocked)
		if not unlocked:
			tab_container.set_tab_title(i, "  ?  ")
		i += 1

#	for item_name in items_dict.keys():
#		var item : Item = add_item(item_name)
#		if item == null or not is_instance_valid(item):
#			print("Ignoring item : " , item_name)
#			continue
#
#		var container = tabs_dict[items_dict[item_name]]
#		var icon = ITEM_ICON_SCENE.instance()
#		icon.set_item(item)
#		container.add_child(icon)
#		icon.connect("pressed", self, "on_icon_pressed", [icon.item])
		

func add_item(item_name) -> Item:
	
	var path : String = ITEMS_BASE_PATH + item_name + ".tscn"
	var item_scene = null
	var file : File = File.new()
	
	if file.file_exists(path):
		item_scene = load(path)
	
	if item_scene == null:
		print("Error : ", self, " couldn't find a resource for object \" " ,item_name , " \"" )
		return null
		
	var new_item = item_scene.instance()
	items_node.add_child(new_item)
	items[item_name] = new_item
	
	return new_item


func on_tab_selected(tab_index : int):
	var tabs = []
	tabs = TABS.duplicate(true)
	
	tab_container.set_tab_title(tab_index, ActiveText[tab_index])
	
	tabs.erase(tab_index)
	
	var items_unlock = load(SAVE_PATH).items_unlock
	
	for tab in tabs:
		if items_unlock.has(ActiveText[tab]):
			if items_unlock[ActiveText[tab]] == false:
				tab_container.set_tab_title(tab, "  ?  ")
			else:
				tab_container.set_tab_title(tab, InactiveText[tab])
		else:
			tab_container.set_tab_title(tab, InactiveText[tab])
	pass
