extends HBoxContainer
class_name Spells_bar

export(String) var CLASS 

export (String, FILE, "*.json") var spells_file_path : String

var cooldowns = [0, 0, 0, 0, 0]

signal spell_used

var spells_list : Dictionary
var spell : Dictionary
var spell_index : int

onready var children = get_child(0).get_children()

func update_display():
	children = get_children()
	var i : int = 0
	for cooldown in cooldowns:
		var label_child = get_child(i).get_child(0)
		if cooldown == 0:
			label_child.text = ""
			label_child.hide()
		if cooldown > 0 :
			label_child.text = str(cooldown)
			label_child.show()
		i += 1


func _ready():
	spells_list = load_spells_list(spells_file_path)



func load_spells_list(file_path) -> Dictionary:
	var file = File.new()
	file.open(file_path, file.READ)
	var spells_list = parse_json(file.get_as_text())
	return spells_list


func _on_TextureButton_pressed():
	spell = spells_list["Spell1"]
	spell_index = 0
	if cooldowns[spell_index] == 0:
		emit_signal("spell_used", spell, spell_index)
	else:
		print("Spell is on cooldown. " , cooldowns[spell_index] , " turns remaining")


func _on_TextureButton2_pressed():
	spell = spells_list["Spell2"]
	spell_index = 1
	if cooldowns[spell_index] == 0:
		emit_signal("spell_used", spell, spell_index)
	else:
		print("Spell is on cooldown. " , cooldowns[spell_index] , " turns remaining")


func _on_TextureButton3_pressed():
	spell = spells_list["Spell3"]
	spell_index = 2
	if cooldowns[spell_index] == 0:
		emit_signal("spell_used", spell, spell_index)
	else:
		print("Spell is on cooldown. " , cooldowns[spell_index] , " turns remaining")


func _on_TextureButton4_pressed():
	spell = spells_list["Spell4"]
	spell_index = 3
	if cooldowns[spell_index] == 0:
		emit_signal("spell_used", spell, spell_index)
	else:
		print("Spell is on cooldown. " , cooldowns[spell_index] , " turns remaining")


func _on_TextureButton5_pressed():
	spell = spells_list["Spell5"]
	spell_index = 4
	if cooldowns[spell_index] == 0:
		emit_signal("spell_used", spell, spell_index)
	else:
		print("Spell is on cooldown. " , cooldowns[spell_index] , " turns remaining")
