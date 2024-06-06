extends Control

var popup_pos := Vector2(0, 20)
var popup_scale := Vector2(0.75, 0.75)

func on_button_pressed(reference : OptionButton):
	reference.get_popup().rect_position += popup_pos
	reference.get_popup().light_mask = 0
#	reference.get_popup().show_on_top = true
#	reference.get_popup().raise()
	reference.get_popup().rect_scale = popup_scale
