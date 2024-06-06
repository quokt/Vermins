extends TextureButton
class_name BuffButton

const BASE_TEXTURE_PATH = "res://Assets/Icons/"

#const SPELLS_PATH = "res://json/"

var current_buff : Buff

var cooldown : int = 0


func set_texture(buff_texture : Texture , reference : Buff):
	#var texture_path = BASE_TEXTURE_PATH + spell_id + ".png"
	self.texture_normal = buff_texture
	
	current_buff = reference

func set_cooldown(new_cooldown : int):
	cooldown = new_cooldown
	$Label.visible = not cooldown in [0, -1]
	$Label.text = str(cooldown)
