extends Button
class_name Button3D

#Used to make the text follow the button appearance when pressed, simulating a 3d effect

const SHADOW_TEXTURE = preload("res://Assets/UI/button_texture.tres")

export var click_y_offset : float = 2.0

var click_size := Vector2()

onready var button_shadow := TextureRect.new()

var default_opacity = Color(0,0,0,0.7)


func _ready() -> void:
	
	keep_pressed_outside = true
	connect("button_down", self, "on_button_down")
	connect("button_up", self, "on_button_up")
	
	add_child(button_shadow)
	button_shadow.texture = SHADOW_TEXTURE
	button_shadow.expand = true
	#button_shadow.stretch_mode = TextureRect.STRETCH_SCALE_ON_EXPAND
	button_shadow.rect_size = rect_size
	button_shadow.rect_position = Vector2(3,3)
	button_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_shadow.show_behind_parent = true
	button_shadow.modulate = default_opacity


func on_button_down() -> void:
	#button_shadow.rect_position = Vector2(2,2)
	button_shadow.rect_scale = Vector2(0.99,0.96)
#	button_shadow.visible = false
	
	if not has_node("Label"):
		return
	$Label.rect_position.y += click_y_offset


func on_button_up() -> void:
	#button_shadow.rect_position = Vector2(3,3)
	button_shadow.rect_scale = Vector2(1.0, 1.0)
#	button_shadow.visible = true
	
	if not has_node("Label"):
		return
	$Label.rect_position.y -= click_y_offset


