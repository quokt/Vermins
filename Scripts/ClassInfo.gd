extends Node2D

onready var class_name_label := $TileMap2/Label

onready var health_label := $Health/Label
onready var energy_label := $Energy/Label
onready var stamina_label := $Stamina/Label
onready var description_label := $Description
onready var initiative_label := $Initiative

var current_actor : Actor

func set_class(_class_name : String) -> void:
#	for child in $ActorRef.get_children():
#		child.queue_free()
	
	var actor_scene = load("res://Characters/" + _class_name + "/" + _class_name + ".tscn")
	if not actor_scene:
		return
		
	
	
	var new_actor : Actor = actor_scene.instance()
#	$ActorRef.add_child(new_actor)
	current_actor = new_actor
	
	class_name_label.text = str(new_actor.CLASS)
	$TileMap2/Label/Shadow.text = class_name_label.text
	
	health_label.text = str(new_actor.base_health_points)
	$Health/Label/Shadow.text = health_label.text
	
	energy_label.text = str(new_actor.base_energy)
	$Energy/Label/Shadow.text = energy_label.text
	
	stamina_label.text = str(new_actor.base_stamina)
	$Stamina/Label/Shadow.text = stamina_label.text
	
	description_label.text = str(new_actor.description)
	$Description/Shadow.text = description_label.text
	
	initiative_label.text = "initiative: " + str(new_actor.initiative)
	$Initiative/Shadow.text = initiative_label.text
	
	
	var base_spell = load("res://Spells/" + _class_name + "/" + "DefaultSpell/DefaultSpell.tres")
	if base_spell:
		$BaseSpellInfo.set_spell(base_spell)
	else:
		$BaseSpellInfo.visible = false
	
	new_actor.queue_free()
	
	pass
