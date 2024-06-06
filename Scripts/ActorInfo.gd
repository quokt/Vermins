extends Node2D

const buff_button_scene = preload("res://Scenes/BuffButton.tscn")
const item_icon_scene = preload("res://Scenes/ItemIcon.tscn")
const giants := ["Spider", "Mantis", "Earthworm", "Rat"]

var base_actor_scale := Vector2(1.447,1.375)
var custom_scales := {
	"Rat" : Vector2(0.9,0.9),
	"Mantis": Vector2(0.9,0.9),
	"Earthworm" : Vector2(0.85,0.85),
	"Spider" : Vector2(1.0,1.0)
}
var giant_actor_scale := Vector2(1.0,1.0)

var base_actor_position := Vector2(-0.423,-0.465)
var custom_positions := {
	"Rat" : Vector2(0,-3),
	"Mantis" : Vector2(-0.423,-1),
	"Spider" : Vector2(1,-2),
	"Earthworm" : Vector2(-0.423,-0.5)
}

signal spell_used

const base_path : String = "res://Characters/"
const PUPPET_PATH : String = "res://Puppets/"

var buff_tooltip

var item_tooltip

onready var actor_sprite := $ActorBg/AnimatedSprite
onready var actor_shadow := $ActorBg/AnimatedSprite/Shadow

onready var health_bg_wide := $HealthBg/HealthBgWide
onready var health_bg_shadow := $HealthBg/Shadow

onready var energy_bg := $EnergyBg

onready var health_label := $HealthBg/Label
onready var health_label_wide := $HealthBg/HealthBgWide/WideLabel
onready var energy_label := $EnergyBg/Label
onready var stamina_label := $StaminaBg/Label

onready var spells_bar := $Spells_UI
onready var spells_bgs := [$SpellBg1, $SpellBg2, $SpellBg3, $SpellBg4, $SpellBg5]

onready var items_displayer := $Items_UI
onready var items_count_label := $ItemButton/Label

onready var buffs_displayer := $Buffs_UI/GridContainer
onready var buffs_count_label := $BuffButton/Label


func _ready():
	spells_bar.connect("spell_used", self, "on_spell_button_pressed")
	_on_BuffWideButton_pressed()


func on_spell_button_pressed(spell, spell_unique_name : String, preview_only = false, button_instance = null):
	if preview_only:
		emit_signal("spell_preview_used", button_instance)
	if spell.cooldown == 0 :
		emit_signal("spell_used", spell, spell_unique_name)
		print("spell used emitted")
	else:
		print("Spell is on cooldown. " , spell.cooldown , " turns remaining")


func set_actor(actor: Actor, preview_only : bool = false) -> void:
	
	#TODO : test this 
	health_label.text = str(actor.current_health_points)
	health_label_wide.text = str(actor.current_health_points) + "/" + str(actor.max_health_points)
	energy_label.text = str(actor.current_energy)
	stamina_label.text = str(actor.current_stamina)
	
	var path : String
	
	if actor is Puppet:
		path = str(PUPPET_PATH + actor.CLASS + "/" + actor.CLASS + ".tres")
	else:
		path = str(base_path + actor.CLASS + "/" + actor.CLASS + ".tres")
		
	var sprite_frames = load(path)
	
	actor_sprite.set_sprite_frames(sprite_frames)
	actor_shadow.set_sprite_frames(sprite_frames)
	actor_sprite.flip_h = true
	actor_shadow.flip_h = actor_sprite.flip_h
	sync_sprite_with_shadow()
	
	if actor.CLASS in giants:
		actor_sprite.scale = custom_scales[actor.CLASS]
		actor_sprite.position= custom_positions[actor.CLASS]
	else:
		actor_sprite.scale = base_actor_scale
		actor_sprite.position = base_actor_position
	
	for bg in spells_bgs:
		bg.visible = false
	if not actor.spells.size() == 0:
		spells_bgs[actor.spells.size()-1].visible = true
	
	spells_bar.set_spells(actor, preview_only)
	
	var spell_tooltip = get_tree().get_nodes_in_group("spell_info")[0]
	spell_tooltip.position = Vector2(36 + actor.spells.size()*18, 65)
	
	for child in buffs_displayer.get_children():
		if child.is_connected("mouse_entered", self, "on_buff_mouse_entered"):
			child.disconnect("mouse_entered", self, "on_buff_mouse_entered")
		if child.is_connected("mouse_exited", self, "on_buff_mouse_exited"):
			child.disconnect("mouse_exited", self, "on_buff_mouse_exited")
		child.free()
	
	for buff in actor.current_buffs.values():
		if buff is Array:
			for buff_ in buff:
				add_buff_icon(buff_)
		else:
			add_buff_icon(buff)
			
	buffs_count_label.text = str(buffs_displayer.get_child_count())
			
	for child in items_displayer.get_children():
		if child.is_connected("mouse_entered", self, "on_item_mouse_entered"):
			child.disconnect("mouse_entered", self, "on_item_mouse_entered")
		if child.is_connected("mouse_exited", self, "on_item_mouse_exited"):
			child.disconnect("mouse_exited", self, "on_item_mouse_exited")
		child.free()
			
	for item in actor.items_node.get_children():
		add_item_icon(item)
		
	items_count_label.text = str(items_displayer.get_child_count())
	
	
	
	
	
func add_item_icon(item : Item) -> void:
	var new_icon := item_icon_scene.instance()
	items_displayer.add_child(new_icon)
	new_icon.set_item(item)
	new_icon.connect("mouse_entered", self, "on_item_mouse_entered", [new_icon])
	new_icon.connect("mouse_exited", self, "on_item_mouse_exited", [new_icon])
	


func add_buff_icon(buff : Buff) -> void:
	if buff == null or not is_instance_valid(buff):
		return
	var new_button = buff_button_scene.instance()
	buffs_displayer.add_child(new_button)
	new_button.set_texture(buff.icon, buff)
	new_button.set_cooldown(buff.turns)
	new_button.rect_scale = Vector2(2, 2)
	new_button.connect("mouse_entered", self, "on_buff_mouse_entered", [new_button])
	new_button.connect("mouse_exited", self, "on_buff_mouse_exited", [new_button])
	


func on_item_mouse_entered(button_instance):
	item_tooltip = get_tree().get_nodes_in_group("item_info")[0]
	item_tooltip.set_item(button_instance.item)
	item_tooltip.visible = true

func on_item_mouse_exited(button_instance):
	item_tooltip = get_tree().get_nodes_in_group("item_info")[0]
	item_tooltip.set_item(button_instance.item)
	item_tooltip.visible = false


func on_buff_mouse_entered(button_instance):
	buff_tooltip = get_tree().get_nodes_in_group("buff_info")[0]
	buff_tooltip.set_buff(button_instance.current_buff)
	buff_tooltip.visible = true
	
func on_buff_mouse_exited(_button_instance):
	buff_tooltip = get_tree().get_nodes_in_group("buff_info")[0]
	buff_tooltip.set_buff({})
	buff_tooltip.visible = false


func sync_sprite_with_shadow() -> void:
	actor_sprite.playing = false
	actor_shadow.playing = false
	actor_sprite.frame = 0
	actor_shadow.frame = 0
	actor_sprite.playing = true
	actor_shadow.playing = true


func _on_mouse_entered_health():
	health_bg_wide.visible = true
	health_bg_shadow.visible = false
	health_label_wide.visible = true
	health_label.visible = false

func _on_mouse_exited_health():
	health_bg_wide.visible = false
	health_bg_shadow.visible = true
	health_label_wide.visible = false
	health_label.visible = true




func _on_ItemButton_pressed():
	$ItemButton.visible = false
	$ItemButtonBgWide.visible = true
	$BuffButton.visible = true
	$BuffButtonBgWide.visible = false
	$Buffs_UI.visible = false
	$Items_UI.visible = true


func _on_BuffButton_pressed():
	$ItemButton.visible = true
	$ItemButtonBgWide.visible = false
	$BuffButton.visible = false
	$BuffButtonBgWide.visible = true
	$Buffs_UI.visible = true
	$Items_UI.visible = false
	


func _on_BuffWideButton_pressed():
	$ItemButton.visible = true
	$ItemButtonBgWide.visible = false
	$BuffButton.visible = true
	$BuffButtonBgWide.visible = false
	$Buffs_UI.visible = false
	$Items_UI.visible = false


func _on_ItemsWideButton_pressed():
	$ItemButton.visible = true
	$ItemButtonBgWide.visible = false
	$BuffButton.visible = true
	$BuffButtonBgWide.visible = false
	$Buffs_UI.visible = false
	$Items_UI.visible = false
