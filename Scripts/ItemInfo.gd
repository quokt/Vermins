extends Control


var item : Item

onready var name_label := $Name
onready var description_label := $ScrollContainer/VBoxContainer/Description

onready var item_icon := $ItemIcon
onready var item_icon_shadow := $ItemIcon/ItemShadow

func set_item(item_ : Item = null) -> void:
	if not item_ or not is_instance_valid(item_):
		name_label.text = ""
		for label in $ScrollContainer/VBoxContainer.get_children():
			label.text = ""
		return
	
	self.item = item_
	
	item_icon.texture = item_.item_texture
	item_icon_shadow.texture = item_.item_texture
	
	for label in $ScrollContainer/VBoxContainer.get_children():
		label.text = ""
	
	name_label.text = str(item_.item_name)
	
	description_label.text = str(item_.description)
	
	
