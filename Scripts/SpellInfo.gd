extends Node2D

var spell : SpellResource

onready var name_label := $Name
onready var energy_label := $Energy/Energy
onready var range_label := $ScrollContainer/VBoxContainer/Range
#onready var targets_label = $ScrollContainer/VBoxContainer/Targets
onready var aoe_label := $ScrollContainer/VBoxContainer/AOE
onready var cooldown_label := $ScrollContainer/VBoxContainer/Cooldown
onready var damage_type_label := $Type/Type
onready var description_label := $Description
onready var crit_label := $Critical/Popup/Label
onready var spell_icon := $SpellButton

onready var crit_popup := $Critical/Popup

func set_spell(spell_ : SpellResource):
	if not spell_ or not is_instance_valid(spell_):
		name_label.text = ""
		for label in $ScrollContainer/VBoxContainer.get_children():
			label.text = ""
		return
	
	self.spell = spell_
	
	spell_icon.set_spell(spell_)
	
	for label in $ScrollContainer/VBoxContainer.get_children():
		label.text = ""
	
	name_label.text = str(spell_.spell_name)
	
	energy_label.text = str(spell_.energy_cost)
	
	var range_modif : String = ""
	if spell_.range_modif == true:
		range_modif = " *"
		
	range_label.text = str("Range : " + str(spell_.min_range) + " - " + str(spell_.max_range) + range_modif)
	
	#cell_label.text = str("Cell : " + str(spell_.cell_mode))
	
	
	aoe_label.text = str("Area Of Effect : " + str(spell_.aoe))
	
	cooldown_label.text = str("Cooldown : " + str(spell_.cooldown))
	
	var damage_type : String = ""
	match spell_.spell_type:
		Spell.SPELL_TYPE.PHYSIC:
			damage_type = "Physic"
		#Spell.SPELL_TYPE.PSYCHIC:
			#damage_type = "Psychic"
		Spell.SPELL_TYPE.MAGIC:
			damage_type = "Magic"
	
	damage_type_label.text = damage_type
	
	description_label.text = str(spell_.description)
	
	crit_label.text = str(spell_.crit_chance*100) + "% : " + str(spell_.critical_effect)
	
	


func _on_MouseDetect_mouse_entered():
	crit_popup.show()
	$Critical.z_index = 1


func _on_MouseDetect_mouse_exited():
	crit_popup.hide()
	$Critical.z_index = 0
