extends Button3D

signal sounds_toggled(bool_value)
signal transparent_props_toggled(bool_value)

const auto_coord_active_right := Vector2(0, 8)
const auto_coord_active_middle := Vector2(1,1)
const auto_coord_active_left := Vector2(2, 8)
const auto_coord_inactive := Vector2(1, 0)

onready var crt_filter = get_tree().get_nodes_in_group("crt_effect")[0]

onready var tabs = [
	$BgWide/Tabs/Tab1,
	$BgWide/Tabs/Tab2
]
onready var tilemap := $BgWide

const down_cells = [
	[Vector2(-8,0), Vector2(-7,0), Vector2(-6,0)],
	[Vector2(-4,0), Vector2(-3,0), Vector2(-2,0)]
]

var first_tile
var middle_tile
var second_tile

func _ready():
	make_tab_active(1)
	
	$BgWide/Tabs/Tab2/Filter.pressed = crt_filter.visible
	
	$BgSmall.visible = true
	$BgWide.visible = false


func make_tab_active(index : int = 0):
	var tab = index -1
	
	first_tile = down_cells[tab][0]
	middle_tile = down_cells[tab][1]
	second_tile = down_cells[tab][2]
	
	tabs[tab].visible = true
	
	tilemap.set_cell(first_tile.x, first_tile.y, 1, false, false, false, auto_coord_active_left)
	tilemap.set_cell(middle_tile.x, middle_tile.y, 1, false, false, false, auto_coord_active_middle)
	tilemap.set_cell(second_tile.x, second_tile.y, 1, false, false, false, auto_coord_active_right)
	
	make_tabs_inactive(index)


func make_tabs_inactive(index : int):
	
	var i = 1 if index-1 == 0 else 0
			
	var tab = down_cells[i]

	tabs[i].visible = false
	
	for cell in tab:
		tilemap.set_cell(cell.x, cell.y,1, false, false, false, auto_coord_inactive)


func on_button_down() -> void:
	#button_shadow.rect_position = Vector2(2,2)
	button_shadow.rect_scale = Vector2(0.0,0.0)
	
	if not has_node("Label"):
		return
	$Label.rect_position.y += 8


func on_button_up() -> void:
	#button_shadow.rect_position = Vector2(3,3)
	button_shadow.rect_scale = Vector2(1.0, 1.0)
	
	if not has_node("Label"):
		return
	$Label.rect_position.y -= 8



func _on_Button_pressed():
	make_tab_active(1)


func _on_Button2_pressed():
	make_tab_active(2)


func _on_ButtonSmall_pressed():
	$BgWide.visible = true
	$BgSmall.visible = false


func _on_ButtonWide_pressed():
	$BgSmall.visible = true
	$BgWide.visible = false


func _on_TransparentProps_toggled(button_pressed):
	emit_signal("transparent_props_toggled", button_pressed)


func _on_Sounds_toggled(button_pressed):
	emit_signal("sounds_toggled", button_pressed)


func _on_Filter_toggled(button_pressed):
	crt_filter.visible = button_pressed
