extends Node2D

#TODO : add (unique) critical effects to spells !
#IDEA : make team building interactive (players choose classes alternatively)

signal team_changed
signal confirm_pressed

export var MAX_COST = 120 

export(String, FILE, "*.tres") var char_file_path : String 
export(String, FILE, "*.tres") var spells_list_path : String
export(String) var spells_path : String
export(String, FILE, "*.tres") var SAVE_PATH : String

onready var actor_icon = preload("res://Scenes/ActorIcon.tscn")
onready var spell_button = preload("res://Scenes/SpellButton.tscn")
onready var spell_bar = preload("res://Scenes/Spells_UI_v2.tscn")
onready var items_bar = preload("res://Scenes/Items_bar.tscn")
onready var color_button = preload("res://Scenes/ColorPicker.tscn")

onready var tilemap = $TileMap
onready var char_list_node = $Tab1/CharList
onready var giants_list_node = $Tab1/GiantsList
onready var char_list_size = char_list_node.get_size()
onready var team_button = $Tab1/MarginContainer/Button
onready var add_spell_button = $Tab2/MarginContainer2/Button
onready var add_item_button = $Tab3/MarginContainer3/Button
onready var confirm_button = $TeamPreview/ConfirmButton

onready var cost_label = $TeamPreview/CurrentCost

onready var item_displayer = $Tab3/ItemDisplayer

onready var spell_info = $Tab2/SpellInfo
onready var item_info = $Tab3/ItemInfo

onready var actor_preview_icon1 = $Tab1/MarginContainer/PanelContainer/ActorIcon
onready var actor_preview_label1 = $Tab1/MarginContainer/PanelContainer/Label
onready var preview_cost1 = $Tab1/MarginContainer/Sprite/Cost
onready var actor_preview_icon2 = $Tab2/MarginContainer2/PanelContainer/ActorIcon
onready var actor_preview_label2 = $Tab2/MarginContainer2/PanelContainer/Label
onready var preview_cost2 = $Tab2/MarginContainer2/Sprite/Cost
onready var actor_preview_icon3 = $Tab3/MarginContainer3/PanelContainer/ActorIcon
onready var actor_preview_label3 = $Tab3/MarginContainer3/PanelContainer/Label
onready var preview_cost3 = $Tab3/MarginContainer3/Sprite/Cost

onready var team_preview_bg = $TeamPreviewBg


var current_actor_preview_icon : Node
var current_actor_preview_label : Node
var current_preview_cost : Node

onready var team_list = $TeamPreview/Icons/TeamList
onready var remove_buttons = $TeamPreview/RemoveButtons
onready var color_buttons = $TeamPreview/CanvasLayer/ColorButtons
onready var confirm_panel = $Layer
onready var line_edit = $Layer/LineEdit
onready var class_info = $Tab1/ClassInfo
var confirm_visible : bool = false


var selected_actor

var actor_icon_scale := Vector2(1.5, 1.5)
var giants_icon_scale := Vector2(3.5, 3.5)
var team_actor_scale := Vector2(1.7, 1.7)
var remove_button_scale := Vector2(0.8, 0.66)

var characters_list
onready var team_count : int = team_list.get_child_count()
const max_team_count = 5

onready var spells_list = $Tab2/SpellsList
const spell_positions : Array = [
	
]
var current_spells : Array

var team_save_index : int = 0

var current_team : Dictionary = {}
var selected_team : Dictionary = {}
var save_team : Dictionary = {}

var current_cost : int = 0

var columns = 5
var lines = 4


#variables used to simulate tab effect
onready var tabs = [
	$Tab1 ,
	$Tab2 ,
	$Tab3
]
const down_cells = [
	[Vector2(2,4), Vector2(3,4), Vector2(4,4)],
	[Vector2(6,4), Vector2(7,4), Vector2(8,4)],
	[Vector2(10,4), Vector2(11,4), Vector2(12,4)]
]
const auto_coord_active_right := Vector2(0, 8)
const auto_coord_active_middle := Vector2(1,1)
const auto_coord_active_left := Vector2(2, 8)
const auto_coord_inactive := Vector2(1, 0)

const color_button_positions : Array = [
	Vector2(-4, -14) ,
	Vector2(-4, 10) ,
	Vector2(-4, 34) ,
	Vector2(-4, 59) ,
	Vector2(-4, 84)
]

var current_tab : int = 1
var first_tile
var middle_tile
var second_tile

var disable_confirm_button : bool = false

func _process(_delta):
	confirm_button.disabled = team_count <= 0 or disable_confirm_button
	confirm_button.visible = not confirm_button.disabled
	team_button.disabled = team_count >= max_team_count or not actor_preview_icon1.visible or int(current_preview_cost.text) > MAX_COST - current_cost 
	confirm_panel.visible = confirm_visible
	cost_label.text = str(MAX_COST - current_cost)
	
#	var test1 : bool = int(current_preview_cost.text) > MAX_COST - current_cost
#	var test2 : bool = team_count == 0
#	var test3 : bool = selected_actor == null
##	var test4 : bool = spell_info and is_instance_valid(selected_actor) and selected_actor.spells.has(spell_info.spell.spell_ID)
##	var test5 : bool = is_instance_valid(selected_actor) and is_instance_valid(selected_actor) and selected_actor.items.has(item_info.item.item_name)
#	var test6 : bool = (is_instance_valid(selected_actor) and selected_actor.get_child(1).get_child_count() >= 5)
#	var test7 : bool = (is_instance_valid(selected_actor) and selected_actor.get_child(2).get_child(0).get_child_count() >= 6)
	
	add_spell_button.disabled = (not spell_info.visible 
									or int(current_preview_cost.text) > MAX_COST - current_cost 
#									or team_count == 0 
									or selected_actor == null
									or not is_instance_valid(selected_actor)
									or selected_actor.spells.has(spell_info.spell.spell_ID)
									or selected_actor.get_child(1).get_child_count() >= 5
									)
	add_item_button.disabled = (not item_info.visible 
									or int(current_preview_cost.text) > MAX_COST - current_cost 
#									or team_count == 0 
									or selected_actor == null
									or not is_instance_valid(selected_actor)
									or selected_actor.items.has(item_info.item.item_name)
									or selected_actor.get_child(2).get_child(0).get_child_count() >= 6
									)
#	if is_instance_valid(selected_actor) and selected_actor.items.has(item_info.item.item_name):
#		pass
	#if is_instance_valid(selected_actor) and not add_item_button.disabled and is_instance_valid(item_info):
		#add_item_button.disabled = selected_actor.items.has(item_info.item.item_name)
	#make_tab_active(current_tab)
	#make_tabs_inactive(current_tab)
	
#	if is_instance_valid(selected_actor):
#		add_spell_button.disabled = selected_actor.get_child(1).get_child_count() >= 5
#		add_item_button.disabled = selected_actor.get_child(2).get_child(0).get_child_count() >= 6


func _ready():
	
	confirm_panel.visible = false
	
	if ResourceLoader.exists(SAVE_PATH):
		var save_file = ResourceLoader.load(SAVE_PATH)
		if save_file :
			#print(str(save_file.player_team))
			pass
	
	make_tab_active(current_tab)
	make_tabs_inactive(current_tab)
	
	place_characters()
	
	for i in [1, 2, 3]:
		set_preview_actor(["void", 0], i)
	
	confirm_button.connect("pressed", self, "on_confirm_pressed")
	item_displayer.connect("item_pressed", self, "on_item_pressed")


#func _unhandled_input(event):
#	if event is InputEventMouseButton:
#		if event.is_action_pressed("mouse_left_click") or event.is_action_pressed("mouse_right_click") :
#			for child in remove_buttons.get_children():
#				child.free()
#			for child in color_buttons.get_children():
#				child.free()


func place_characters():
	
	place_giants()
	
	for child in char_list_node.get_children():
		child.queue_free()
	
	var characters_list_ = load_char_list()
#Make characters appear in a grid since GridContainer brakes the buttons
	var char_unlocks : Dictionary = ResourceLoader.load(SAVE_PATH).characters_unlock
	
	var i : int = 0
	var i_x : int = 1
	var i_y : int = 1
	var x_pos
	var y_pos
	for column in columns:
		i_y = 1
		x_pos = char_list_size.x/(columns + 1) * i_x
		for line in lines:
			y_pos = char_list_size.y/(lines+ 1) * i_y
			var instance = actor_icon.instance() as Button

			char_list_node.add_child(instance)
			
			instance.unlocked = char_unlocks[characters_list_[i][0]]
			instance.set_character(characters_list_[i])
			instance.rect_position = Vector2(x_pos, y_pos)
			instance.rect_scale = actor_icon_scale
			instance.connect("pressed", self, "on_char_pressed", [characters_list_[i], instance])
			i += 1
			i_y += 1
			
		i_x += 1
		


func place_giants():
	
	var characters_list_ = load_giants_list()
	#Make characters appear in a grid since GridContainer brakes the buttons
	var char_unlocks : Dictionary = ResourceLoader.load(SAVE_PATH).characters_unlock
	
	var i : int = 0
	for giant in characters_list_:
		var actor_icon = giants_list_node.get_child(i)
		if actor_icon is ActorIcon:
			actor_icon.unlocked = char_unlocks[characters_list_[i][0]]
			actor_icon.set_character(giant)
			actor_icon.connect("pressed", self, "on_char_pressed", [characters_list_[i], actor_icon])
		i += 1
#	var grid_size := Vector2(2,2)
#
#	var i : int = 0
##	var i_x : int = 1
##	var i_y : int = 1
#	var x_pos
#	var y_pos
#	for x in grid_size.x:
##		i_y = 1
#		x_pos = char_list_size.x/(grid_size.x + 1) * (x+1)
#		for y in grid_size.y:
#			y_pos = char_list_size.y/(grid_size.y+ 1) * (y+1)
#			var instance = actor_icon.instance() as Button
#
#			giants_list_node.add_child(instance)
#
#			instance.unlocked = char_unlocks[characters_list_[i][0]]
#			instance.set_character(characters_list_[i])
#			instance.rect_position = Vector2(x_pos, y_pos)
#			instance.rect_scale = giants_icon_scale
#			instance.connect("pressed", self, "on_char_pressed", [characters_list_[i], instance])
#			i += 1
##			i_y += 1
#
##		i_x += 1


func on_char_pressed(character : Array, button_instance = null):
	print(character[0], " pressed")
	
	if button_instance != null :
		if button_instance.unlocked == false:
			return
	
	set_preview_actor(character, 1)
	#set_preview_actor(character, 2)
	#current_spells = load_spells_list(character[0])
	#display_spells(current_spells, character[0])
	#selected_actor = null
	
#	for child in remove_buttons.get_children():
##		child.visible = false
#		child.free()
#
#	for child in color_buttons.get_children():
#		child.free()
#
#	for child in team_list.get_children():
#		child.set_outline_color(Color.transparent)


#func on_team_char_pressed(index):
#	pass


func on_confirm_pressed():
	confirm_visible = true
	for child in color_buttons.get_children():
		child.free()
	for child in remove_buttons.get_children():
		child.free()


func load_team(team : Dictionary):
	for i in [1, 2, 3]:
		set_preview_actor(["void", 0], i)
	
	current_cost = 0
	
	for child in team_list.get_children():
		child.free()
		
	for child in remove_buttons.get_children():
		child.free()
	
	for actor in team:
		var color
		var color_name
		if team[actor].has("color"):
			if team[actor]["color"] is Array:
				color = team[actor]["color"][0]
				color_name = team[actor]["color"][1]
			else:
				color = team[actor]["color"]
				color_name = "Color.white"
		else:
			color = Color.white
			color_name = "Color.white"
		add_character(team[actor]["class"], team[actor]["spells"], team[actor]["items"], color, color_name)


func save_team():
	if team_save_index == 0:
		print("Error : no team selected")
		return -1
	
	save_team = {}
	var team_save_name : String = "team" + str(team_save_index)
	var team_name : String
	if line_edit.text == "":
		team_name = line_edit.placeholder_text
	else:
		team_name = line_edit.text
	var game_data = ResourceLoader.load(SAVE_PATH)

	
	var i : int = 1	
	for character in team_list.get_children():
		
		var save_spells = {}
		var save_items = []
		var color = character.get_outline_color()
		var j : int = 1
		for spell_button_ in character.get_child(1).get_children():
			var amount : int = 0
#			if new_actor.spells.has(spell_id):
#				j += 1
#				spell_id += str(j)
			if save_spells.has(spell_button_.spell):
				amount = save_spells[spell_button_.spell][2] + 1
				
			save_spells[spell_button_.spell] = [spell_button_.spell_ID, spell_button_.character_name, amount]

		for item_name in character.items:
			save_items.append(item_name)

			
		save_team[i] = {
			"class" : [character.character_name, character.character_cost],
			"spells" : save_spells.duplicate(true),
			"items" : save_items.duplicate(true),
			"color" : [color , character.color_name]

		}
		i += 1
	
	game_data.set(team_save_name, save_team)
	game_data.set(str(team_save_name+"_name"), team_name)
	var result = ResourceSaver.save(SAVE_PATH, game_data)
#	print(str(ResourceLoader.load(SAVE_PATH).get(team_save_name)))

	return result


func set_preview_actor(character : Array, tab_index : int = current_tab, ignore_actor_cost : bool = false):
	if tab_index != 0:
		current_actor_preview_icon = get("actor_preview_icon" + str(tab_index))
		current_actor_preview_label = get("actor_preview_label" + str(tab_index))
		if not ignore_actor_cost:
			current_preview_cost = get("preview_cost" + str(tab_index))
	team_count = team_list.get_child_count()
	var not_void : bool = not character[0] == "void"
	if not current_actor_preview_icon or not current_actor_preview_label or not current_preview_cost:
		return
		
	if not ignore_actor_cost:
		current_preview_cost.visible = not_void
	
	if not_void:
		current_actor_preview_icon.set_character(character)
		class_info.set_class(character[0])
		current_actor_preview_label.text = character[0]
		if current_tab == 1:
			if not ignore_actor_cost:
				current_preview_cost.text = str(character[1])
		elif not ignore_actor_cost:
			current_preview_cost.visible = false
		
	current_actor_preview_icon.visible = not_void
	current_actor_preview_label.visible = not_void
	spells_list.visible = (not_void or tab_index != 2) and (selected_actor != null and is_instance_valid(selected_actor))


func load_char_list() -> Dictionary:
	var res = ResourceLoader.load(char_file_path)
	
	var char_list = res.characters_list
	return char_list
	
func load_giants_list() -> Dictionary:
	var res = ResourceLoader.load(char_file_path)
	
	var char_list = res.giants_list
	return char_list

func load_spells_list(character : String) -> Array:
	
	var spells_res = ResourceLoader.load(spells_list_path)
	var spells_list_ = spells_res.get(character)
	return spells_list_


func add_character(character : Array, spells : Dictionary = {}, items : Array = [], outline_color : Color = Color.white, color_name : String = "Color.white", set_selected : bool = false):
	var actor_instance = actor_icon.instance()
	var spells_bar_instance = spell_bar.instance()
	var items_bar_instance = items_bar.instance()
	
	actor_instance.set_character(character)
	if character[0] in actor_instance.giants:
		actor_instance.get_node("AnimatedSprite").scale = Vector2(2,2)
	actor_instance.index = team_list.get_child_count() + 1
	actor_instance
	
	actor_instance.add_child(spells_bar_instance)
	
					
	spells_bar_instance.alignment = BoxContainer.ALIGN_CENTER
	spells_bar_instance.rect_scale = Vector2(0.8, 0.8)
	spells_bar_instance.rect_position = Vector2(25, 40)
	spells_bar_instance.light_mask = 0
	
	actor_instance.add_child(items_bar_instance)
	
	items_bar_instance.rect_scale = Vector2(0.82, 0.82)
	items_bar_instance.rect_position = Vector2(48, 5)
	items_bar_instance.light_mask = 0
	
	team_list.add_child(actor_instance)
	

#	var base_spell = get_base_spell(character[0])
#	if not base_spell == null:
#		spells_bar_instance.add_preview_spell(base_spell, character[0], true)
	
#	var first = true
	for spell in spells: 
		for s in spells[spell][2] + 1:
#			if spell == base_spell and first:
#				first = false
#				continue
			current_cost += spell.cost
			spells_bar_instance.add_preview_spell(spell, character[0])
			actor_instance.spells.append(str(spell.spell_ID))
	
	for item_name in items:
		var item = item_displayer.items[item_name]
		current_cost += item.cost
		items_bar_instance.add_preview_item(item, actor_instance)
		actor_instance.items.append(str(item.item_name))
	
	current_cost += character[1]
	
	actor_instance.rect_scale = team_actor_scale
	actor_instance.visible = true
	actor_instance.set_outline_color(outline_color, true)
	actor_instance.set_outline_color(Color.transparent)
	actor_instance.color_name = color_name
	
	actor_instance.light_mask = 0
	for child in actor_instance.get_children():
		child.light_mask = 0
		for sub_child1 in child.get_children():
			sub_child1.light_mask = 0
			for sub_child2 in sub_child1.get_children():
				sub_child2.light_mask = 0
				for sub_child3 in sub_child2.get_children():
					sub_child3.light_mask = 0
#					for sub_child4 in sub_child3.get_children():
#						sub_child4.light_mask = 0
#						for sub_child5 in sub_child4.get_children():
#							sub_child5.light_mask = 0
	#yield(instance, "ready")
	
	actor_instance.connect("pressed" , self, "on_team_actor_pressed", [actor_instance])
	spells_bar_instance.connect("spell_preview_used", self, "on_spell_used", [actor_instance, spells_bar_instance])
	items_bar_instance.connect("item_preview_pressed", self, "on_item_used")
	
	team_count = team_list.get_child_count()
	
	#yield(get_tree().create_timer(0.5),"timeout")
	if set_selected:
		yield(get_tree().create_timer(0.08),"timeout")
		#yield(get_tree(),"idle_frame")
		on_team_actor_pressed(actor_instance)


func get_base_spell(character_name : String) -> SpellResource:
	var spells_list = load(spells_list_path)
	if not spells_list.get(character_name) is Array:
		return null
		
	if spells_list.get(character_name).size() == 0:
		return null
		
	var spell_name = spells_list.get(character_name)[0]
	var spell_res_path : String = spells_path + character_name + "/" + spell_name + "/" + spell_name + ".tres"
	var spell_res = load(spell_res_path)
	
	return spell_res
	


func on_spell_used(button_instance : Node, _actor, spells_bar) -> void:
	current_cost -= button_instance.spell.cost
	_actor.spells.erase(button_instance.spell_ID)
	
	if spells_bar.has_method("on_mouse_exited"):
		spells_bar.on_mouse_exited(button_instance, {})
	button_instance.queue_free()


func on_item_used(item : Item , button_instance : Node) -> void:
	current_cost -= button_instance.item.cost
	button_instance.actor.items.erase(button_instance.item.item_name)
	
	
	get_tree().get_nodes_in_group("item_info")[0].visible = false
	button_instance.queue_free()


func display_spells(spells : Array, character_name : String = selected_actor.character_name) -> void:
	
	spells_list.visible = not spells == []
	

	var i : int = 0
	for spell in spells:
		var button = spells_list.get_children()[i]
		if button.is_connected("pressed", self, "on_spell_button_pressed"):
			button.disconnect("pressed", self, "on_spell_button_pressed")
		
		for child in button.get_children():
			if child is SpellResource:
				child.free()
			
		var new_spell = get_spell_resource(spell, character_name)
		button.set_spell(new_spell)
		button.connect("pressed", self, "on_spell_button_pressed", [new_spell])
		i += 1
	


func get_spell_resource(spell : String, character_name : String = selected_actor.character_name) -> SpellResource:
	
	var spell_res_path : String = spells_path + character_name + "/" + spell + "/" + spell + ".tres"
	var spell_res = load(spell_res_path)
	
	return spell_res


func on_team_actor_pressed(instance_ref):
	
	if current_tab: #!= 1:
		selected_actor = instance_ref
		set_preview_actor([instance_ref.character_name, instance_ref.character_cost], 2, true)
		set_preview_actor([instance_ref.character_name, instance_ref.character_cost], 3, true)
		
		current_spells = load_spells_list(instance_ref.character_name)
		display_spells(current_spells, instance_ref.character_name)
		spell_info.visible = false
	
	if current_tab == 2:
		pass
	
	for child in remove_buttons.get_children():
#		child.visible = false
		child.free()
		
	for child in color_buttons.get_children():
		child.free()
		
	for child in team_list.get_children():
		child.set_outline_color(Color.transparent)
		
	#button.visible = true

	var new_button = Button3D.new()

	remove_buttons.add_child(new_button)

	new_button.rect_size = instance_ref.rect_size * remove_button_scale
	new_button.rect_position = instance_ref.rect_position
	new_button.text = "X"
	new_button.light_mask = 0
	#new_button.connect("pressed", self, "on_remove_actor_pressed", [instance_ref, new_button])
	
	var new_color_button = color_button.instance()
	
	new_button.connect("pressed", self, "on_remove_actor_pressed", [instance_ref, new_button, new_color_button])
	
	color_buttons.add_child(new_color_button)
	
	new_color_button.rect_size = new_button.rect_size #+ Vector2(-100,0)
	new_color_button.index = max(instance_ref.index -1, 0)
	new_color_button.get_popup().rect_scale = Vector2(1,1)
	new_color_button.rect_position = color_button_positions[new_color_button.index]
	new_color_button.light_mask = 0
	new_color_button.connect("pressed", color_buttons, "on_button_pressed", [new_color_button])
	new_color_button.connect("item_selected", self, "on_color_selected", [new_color_button,instance_ref])
	var array = new_color_button.COLORS_NAMES
	var out_color = instance_ref.color_name
	var index = array.find(out_color)
	new_color_button.selected = index
	#new_color_button.text = "Color"
	
	instance_ref.set_outline_color(instance_ref.outline_color)
	


func on_color_selected(color_index ,color_button_, icon_ref):
	var selected_color = color_button_.COLORS[color_index]
	icon_ref.set_outline_color(selected_color, true)
	icon_ref.color_name = color_button_.COLORS_NAMES[color_index]
	icon_ref.color_index = color_index
	

func on_remove_actor_pressed(instance_ref, button, color_button_ref):
	if not is_instance_valid(instance_ref):
		print("Error in " + str(self))
		return
	
	current_cost -= instance_ref.character_cost
	var spells_bar_node = instance_ref.get_child(1)
	var items_bar_node = instance_ref.get_child(2)
	for child in spells_bar_node.get_children():
		if child.is_base_spell:
			continue
		current_cost -= child.spell.cost
	
	for item_icon in items_bar_node.grid_container.get_children():
		if not is_instance_valid(item_icon):
			continue
		current_cost -= item_icon.item.cost
		
	
	spells_bar_node.queue_free()
	
	for child in team_list.get_children():
		if child.index > instance_ref.index:
			child.index -= 1
	
	instance_ref.queue_free()
	
	button.queue_free()
		
	color_button_ref.queue_free()
	
	item_info.visible = false
	
	set_preview_actor(["void", 0], 2)
	set_preview_actor(["void", 0], 3)
	display_spells([])
	add_spell_button.disabled = true
	team_count -= 1


func _on_Cancel_pressed():
	confirm_visible = false


func _on_real_confirm_pressed():
	var result = save_team()
	if result == OK:
		print("Saved succesfully")
		#var game_data = ResourceLoader.load(SAVE_PATH)
#		print(str(game_data.player_team))
		emit_signal("team_changed")
		emit_signal("confirm_pressed")
		disable_confirm_button = true
		for child in team_list.get_children():
			child.queue_free()
		
	confirm_visible = false
	
	yield(get_tree().create_timer(1.0),"timeout")
	disable_confirm_button = false


func _on_add_spell_pressed():
	

#	selected_actor.spells.append(spell_info.spell)
	
	if selected_actor == null or not is_instance_valid(selected_actor):
		add_spell_button.disabled = true
		return
		
	current_cost += spell_info.spell.cost
	
	selected_actor.get_child(1).add_preview_spell(spell_info.spell, selected_actor.character_name)
	selected_actor.spells.append(str(spell_info.spell.spell_ID))
	
	
	spell_info.visible = false
	spell_info.set_spell({})
	current_preview_cost.text = ""
	current_preview_cost.visible = false
	
	
func _on_add_item_pressed():
	if selected_actor == null or not is_instance_valid(selected_actor):
		add_item_button.disabled = true
		return
	current_cost += item_info.item.cost
	
#	if selected_actor != null and is_instance_valid(selected_actor):
	selected_actor.get_child(2).add_preview_item(item_info.item, selected_actor)
	selected_actor.items.append(str(item_info.item.item_name))
		
	
		
	item_info.visible = false
	item_info.set_item(null)
	current_preview_cost.text = ""
	current_preview_cost.visible = false


func _on_team_add_pressed():
	var new_color_button = color_button.instance()
	new_color_button.visible = false
	add_child(new_color_button)
#	color_buttons.add_child(new_color_button)
#	new_color_button.rect_size = instance_ref.rect_size * remove_button_scale
#	new_color_button.index = max(instance_ref.index -1, 0)
#	new_color_button.rect_position = color_button_positions[new_color_button.index]
#	new_color_button.light_mask = 0
#	new_color_button.connect("pressed", color_buttons, "on_button_pressed", [new_color_button])
#	new_color_button.connect("item_selected", self, "on_color_selected", [new_color_button,instance_ref])
	
	var colors_list = new_color_button.COLORS.duplicate()
	var colors_name = new_color_button.COLORS_NAMES.duplicate()
	var random_index = randi()%colors_list.size()
	var random_color = colors_list[random_index]
	var color_name = colors_name[random_index]
	add_character([actor_preview_icon1.character_name, actor_preview_icon1.character_cost], {}, [], random_color, color_name, true)
	
	new_color_button.queue_free()

	set_preview_actor(["void", 0], 1)
	if team_count == max_team_count:
		team_button.disabled = true


func on_spell_button_pressed(spell : SpellResource):
	spell_info.visible = true
	spell_info.set_spell(spell)
	current_preview_cost.text = str(spell.cost)
	current_preview_cost.visible = true


func on_item_pressed(item : Item) -> void:
	item_info.visible = true
	item_info.set_item(item)
	current_preview_cost.text = str(item.cost)
	current_preview_cost.visible = true




func _on_Tab1_pressed():
	if current_tab != 1:
#		set_preview_actor(["void", 0], 1)
		current_preview_cost = preview_cost1
		
	current_tab = 1
	make_tab_active(current_tab)
	make_tabs_inactive(current_tab)


func _on_Tab2_pressed():
	if current_tab != 2:
#		set_preview_actor(["void", 0], 2)
		add_spell_button.disabled = true
		spell_info.visible = false
		spell_info.set_spell({})
		current_preview_cost = preview_cost2
	current_tab = 2
	make_tab_active(current_tab)
	make_tabs_inactive(current_tab)


func _on_Tab3_pressed():
	if current_tab != 3:
		current_preview_cost = preview_cost3
		pass
	current_tab = 3
	make_tab_active(current_tab)
	make_tabs_inactive(current_tab)


func make_tab_active(index : int = 0):
	var tab = index -1
	
	first_tile = down_cells[tab][0]
	middle_tile = down_cells[tab][1]
	second_tile = down_cells[tab][2]
	
	tabs[tab].visible = true
	
	tilemap.set_cell(first_tile.x, first_tile.y, 1, false, false, false, auto_coord_active_left)
	tilemap.set_cell(middle_tile.x, middle_tile.y, 1, false, false, false, auto_coord_active_middle)
	tilemap.set_cell(second_tile.x, second_tile.y, 1, false, false, false, auto_coord_active_right)


func make_tabs_inactive(index : int):
	var active_tab = index -1
	var first_tab
	var second_tab
	var first_index
	var second_index
	
	match active_tab:
		0:
			first_index = 1
			second_index = 2
		1:
			first_index = 0
			second_index = 2
		2:
			first_index = 0
			second_index = 1
			
	first_tab = down_cells[first_index]
	second_tab = down_cells[second_index]
	tabs[first_index].visible = false
	tabs[second_index].visible = false
	
	for cell in first_tab:
		tilemap.set_cell(cell.x, cell.y,1, false, false, false, auto_coord_inactive)
	for cell in second_tab:
		tilemap.set_cell(cell.x, cell.y,1, false, false, false, auto_coord_inactive)



func _on_BackButton_pressed():
	for child in color_buttons.get_children():
		child.free()
	for child in remove_buttons.get_children():
		child.free()



func _on_actor_info_entered():
	#TODO : add method to change the class of ClassInfo.tscn
	class_info.visible = class_info.current_actor != null

func _on_actor_info_exited():
	class_info.visible = false


func _on_Giants_pressed():
	var show_giants : bool = not giants_list_node.visible
	char_list_node.visible = not show_giants
	giants_list_node.visible = show_giants
	$Tab1/Giants/Label.text = "giants" if not show_giants else "vermins"
