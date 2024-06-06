extends Control

signal item_preview_pressed(item, button)

onready var grid_container = $GridContainer

var item_icon = preload("res://Scenes/ItemIcon.tscn")

var items : Dictionary = {}

func add_preview_item(item : Item, actor_ref = null) -> void:
		
	if not is_instance_valid(item):
		return
		
	var new_button = item_icon.instance()
	new_button.set_item(item)
	new_button.set_light()
	new_button.actor = actor_ref
	new_button.show_bg(false)
	
	grid_container.add_child(new_button)
	
	items[item.item_name] = new_button
	
	new_button.item = item
	new_button.connect("pressed", self, "on_item_button_pressed", [item , new_button])
	new_button.connect("mouse_entered", self, "on_mouse_entered", [new_button, item])
	new_button.connect("mouse_exited", self, "on_mouse_exited", [new_button, item])


func on_item_button_pressed(item : Item, button):
	emit_signal("item_preview_pressed", item, button)
	
	
func on_mouse_entered(new_button, item):
	new_button.preview_hover(true)
	
	
func on_mouse_exited(new_button, item):
	new_button.preview_hover(false)
