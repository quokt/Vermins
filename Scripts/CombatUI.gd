extends Control

signal spell_used()
signal end_turn_pressed()
signal move_button_pressed()
signal attack_button_pressed()
signal back_button_pressed()

const buff_button_scene = preload("res://Scenes/BuffButton.tscn")

var energy : int

var stamina : int

var cooldowns := {}

var active_effects := {}

var spell_bar_scale := Vector2(0.4, 0.4)

var buff_description : String

onready var turn_count_label := $TurnCount/Label
onready var move_button := $MoveButton
onready var attack_button := $AttackButton
onready var back_button := $BackButton
onready var base_spell_info := $Node2D
onready var end_turn_button := $EndTurnButton
onready var end_turn_button_label := $EndTurnButton/Label
#onready var tilemap = $UI_TileMap

onready var actor_info_node := $ActorInfo

func _ready():
	#spells_bar.grow_horizontal = Control.GROW_DIRECTION_END
		#connects end-turn button
	end_turn_button.connect("pressed", self, "end_turn_pressed")
	
	#connects move_button
	move_button.connect("pressed", self, "move_button_pressed")
	
	attack_button.connect("pressed", self, "attack_button_pressed")
	
	back_button.connect("pressed", self, "back_button_pressed")
	
	actor_info_node.connect("spell_used", self, "on_spell_requested")


func set_preview_actor(actor : Actor, preview_only = false):
	
	actor_info_node.set_actor(actor, preview_only)
	if actor.default_spell and actor.default_spell is Spell:
		base_spell_info.set_spell(actor.default_spell)
	
	attack_button.visible = not preview_only
	move_button.visible = not preview_only
	back_button.visible = preview_only
	
	get_tree().get_nodes_in_group("buff_info")[0].visible = false
	get_tree().get_nodes_in_group("item_info")[0].visible = false
	


#func change_spell_bar(actor : Actor):
#	actor_info_node.set_actor(actor)

	

func set_end_turn_button(enabled : bool):
	end_turn_button.disabled = not enabled



func on_spell_requested(spell : Spell, spell_unique_name : String = "") :
	emit_signal("spell_used", spell, spell_unique_name)


func end_turn_pressed():
	print("combat_ui sent end_turn signal")
	emit_signal("end_turn_pressed")
#	set_end_turn_button(false)
#	yield(get_tree().create_timer(1.0),"timeout")
#	set_end_turn_button(true)


func attack_button_pressed():
	emit_signal("attack_button_pressed")


func move_button_pressed():
	emit_signal("move_button_pressed")


func back_button_pressed():
	emit_signal("back_button_pressed")

#func update_display(actor : Actor):
#	actor_info_node.set_actor(actor)
	

func get_cooldown(spell_index : int):
	return cooldowns[spell_index]


func _on_AttackButton_mouse_entered():
	base_spell_info.visible = true


func _on_AttackButton_mouse_exited():
	base_spell_info.visible = false
