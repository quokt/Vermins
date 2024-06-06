extends TextureButton
class_name SpellButton

const BASE_TEXTURE_PATH = "res://Assets/Icons/"

const SPELLS_PATH = "res://json/"

var spell : SpellResource
var is_base_spell : bool = false
var spell_ID := ""
var character_name := ""
var cooldown : int = 0

var positions : Dictionary = {
	"up" : Vector2(12,12.5),
	"down" : Vector2(13,13.5)
}

onready var red_cross = get_node_or_null("Bg/RedCross")
onready var spell_sprite := $Bg/SpellIcon


func set_enabled(value : bool = true) -> void:
	disabled = not value
	$Bg.position = positions["up"] if value else positions["down"]-Vector2(0.5,0.5)
	modulate = Color(1,1,1,1) if value else Color(0.5,0.5,0.5,1.0) 
	


func set_light():
	light_mask = 0
	for child in get_children():
		child.light_mask = 0
		for child2 in child.get_children():
			child2.light_mask = 0
			for child3 in child2.get_children():
				child3.light_mask = 0


func set_spell(spell_res : SpellResource) -> void:
	if spell_res == null:
		return
	
	self.spell = spell_res
	self.spell_ID = spell_res.spell_ID
	self.character_name = spell_res.character
	set_texture(spell_res.icon)


func set_texture(new_texture : Texture) -> void:
	spell_sprite.texture = new_texture
	#texture_normal = new_texture


func preview_hover(value : bool) -> void:
	$Bg.z_index = value as int
	if red_cross:
		red_cross.visible = value and not is_base_spell


func set_cooldown(value : int):
	cooldown = value
	$Label.visible = cooldown != 0
	$Label.text = str(cooldown)


func _on_button_down():
	$Bg.position = positions["down"]


func _on_button_up():
	$Bg.position = positions["up"]
