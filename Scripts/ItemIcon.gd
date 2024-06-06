extends TextureButton

const BASE_TEXTURE_PATH = "res://Assets/Items/"


var tooltip
var item : Item

var actor

onready var red_cross = get_node_or_null("RedCross")


func set_light():
	light_mask = 0
	for child in get_children():
		child.light_mask = 0
		for child2 in child.get_children():
			child2.light_mask = 0


func set_item(item_ : Item):
	$ItemIcon.texture = item_.item_texture
	$ItemIcon/Shadow.texture = item_.item_texture
	#self.texture_normal = item_.item_texture
	self.item = item_


func preview_hover(value : bool) -> void:
	red_cross.visible = value
	tooltip = get_tree().get_nodes_in_group("item_info")[0]
	tooltip.visible = value

	if value:
		tooltip.set_item(item)
	else:
		tooltip.set_item(null)


func show_bg(value : bool = true) -> void:
	$Bg.visible = value
