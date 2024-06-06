extends HBoxContainer

signal spell_used(spell)
signal spell_preview_used(button_instance)

const SPELLS_LIST = preload("res://Spells/SpellsList.tres") 

var spell_button = preload("res://Scenes/SpellButton.tscn")
var spell_info = preload("res://Scenes/SpellInfo.tscn")

onready var tooltip = get_tree().get_nodes_in_group("spell_info")[0]

var spell_info_scale := Vector2(0.3, 0.3)

var mouse_in : bool = false

var spells := {}

var spells_list : Array
var player_team_index : int = 1


func add_preview_spell(spell : SpellResource, _classname : String, base_spell : bool = false) -> void:
	
	if not is_instance_valid(spell):
		return
		
	var new_button = spell_button.instance()
	self.add_child(new_button)
	new_button.set_light()
	new_button.set_spell(spell)
	new_button.set_cooldown(0)
	#self.add_child(new_button)
	spells[spell.spell_ID] = new_button
	new_button.spell = spell
	
	new_button.is_base_spell = base_spell
	
	if not base_spell:
		new_button.connect("pressed", self, "on_spell_button_pressed", [spell , "", true, new_button])
	new_button.connect("mouse_entered", self, "on_mouse_entered", [new_button, spell, true])
	new_button.connect("mouse_exited", self, "on_mouse_exited", [new_button, spell, true])


func set_spells(actor : Actor , preview_only : bool = false) -> void:
	
	if actor == null:
		return
	
	spells = {}
	
	for child in get_children():
		child.free()
		
	#var spells_file = load_spells_list()
	
	for spell_node in actor.spells_node.get_children():
		if spell_node.ignore_spell == true or spell_node.default_spell:
			continue
			
		var spell_id : String = spell_node.spell_ID
		
		#if spell_name[-1].is_valid_integer():
			#spell_id.erase((spell_id.length() -1), 1)
		#print(spell_id)
		var res_path
		if actor is Puppet:
			res_path = "res://Spells/" + "Puppets/" + actor.CLASS + "/" + spell_id + "/" + spell_id + ".tres"
		else:
			res_path = "res://Spells/" + actor.CLASS + "/" + spell_id + "/" + spell_id + ".tres"
			
		var spell_res = load(res_path)
		
		#var scene_path = "res://Spells/" + actor.CLASS + "/" + spell_id + "/" + spell_id + ".tscn"
		#var spell_scene = load(scene_path).instance()
		#actor.spells_node.add_child(spell_scene)
		
		var new_button = spell_button.instance()
		self.add_child(new_button)
		new_button.set_spell(spell_res)
		new_button.set_cooldown(spell_node.cooldown)
		var disabled : bool = true
		if actor.is_multiplayer:
			disabled = (spell_node.energy_cost > actor.current_energy
						or spell_node.cooldown > 0
						or not actor.is_network_master()
						or actor.has_node("AiControl"))
		else:
			disabled = (spell_node.energy_cost > actor.current_energy
						or spell_node.cooldown > 0
						or actor.team != Actor.TEAMS.SERVER
						or actor.has_node("AiControl"))
		
		new_button.set_enabled(not disabled)
		spells[spell_id] = new_button
		if not preview_only:
			new_button.connect("pressed", self, "on_spell_button_pressed", [spell_node , spell_id])
		new_button.connect("mouse_entered", self, "on_mouse_entered", [new_button, spell_res])
		new_button.connect("mouse_exited", self, "on_mouse_exited", [new_button, spell_res])


func on_mouse_entered(_button_instance : Node, spell : SpellResource, preview : bool = false):
	tooltip = get_tree().get_nodes_in_group("spell_info")[0]
	if preview:
		_button_instance.preview_hover(true)
	#print("mouse_entered")
#	mouse_in = true
#	yield(get_tree().create_timer(1), "timeout")
#	if mouse_in == true and tooltip != null:
#		tooltip.set_spell(spell)
#		tooltip.visible = true
	tooltip.set_spell(spell)
	tooltip.visible = true



func on_mouse_exited(_button_instance : Node, _spell : SpellResource, preview : bool = false):
	tooltip = get_tree().get_nodes_in_group("spell_info")[0]
	if preview:
		_button_instance.preview_hover(false)
	#print("mouse_exited")
#	mouse_in = false
	tooltip.set_spell({})
	tooltip.visible = false


func on_spell_button_pressed(spell, spell_unique_name : String, preview_only = false, button_instance = null):
	if preview_only:
		emit_signal("spell_preview_used", button_instance)
	if spell.cooldown == 0 :
		emit_signal("spell_used", spell, spell_unique_name)
		print("spell used emitted")
	else:
		print("Spell is on cooldown. " , spell.cooldown , " turns remaining")


func load_spells_list() -> Dictionary:
	var file = SPELLS_LIST
	var spells_list_ = file.duplicate(true)
	return spells_list_


func update_cooldowns(actor : Actor):
	set_spells(actor)
	
	if spells.empty() :
		return
	
	
	for spell_name in actor.cooldowns.keys():
		spells[spell_name].set_cooldown(actor.cooldowns[spell_name])
