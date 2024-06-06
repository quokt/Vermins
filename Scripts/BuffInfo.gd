extends Control

var buff : Buff

onready var name_label = $Name
onready var cooldown_label = $ScrollContainer/VBoxContainer/Cooldown
onready var caster_label = $ScrollContainer/VBoxContainer/Caster
onready var damage_type_label = $ScrollContainer/VBoxContainer/DamageType
onready var description_label = $ScrollContainer/VBoxContainer/Description

func set_buff(buff_ : Buff):
	if not buff_ or not is_instance_valid(buff_):
		name_label.text = ""
		for label in $ScrollContainer/VBoxContainer.get_children():
			label.text = ""
		return
	
	self.buff = buff_
	
	var description_text : String
	
	for label in $ScrollContainer/VBoxContainer.get_children():
		label.text = ""
	
	name_label.text = str(buff_.buff_name)
	
	cooldown_label.text = str("Turns : " + str(buff_.turns))
	
	caster_label.text = str("Caster : " + str(buff_.caster))
	
	damage_type_label.text = ""
	
	if buff_.description != "":
		description_label.text = str(buff_.description)
	else:
		description_text = "No description"
