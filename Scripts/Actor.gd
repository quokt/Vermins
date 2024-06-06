extends Area2D
class_name Actor

const BUFFS_PATH : String = "res://Buffs/"

var is_multiplayer : bool = false

enum TEAMS {SERVER, CLIENT}
var team

enum AI_TYPES {MELEE, RANGE, PROTECTOR}
var ai_type = AI_TYPES.MELEE

signal damage_taken()
signal heal_received()
signal damage_prevented()
signal move_finished()
signal spell_cast()
signal died()
signal actor_pressed()
signal energy_spent()
signal stamina_spent()

var puppets : Dictionary = {}  #puppet_name : [puppet1_ref , puppet2_ref] 

var default_spell

var controlable : bool = true

var active : bool = false
var dead : bool = false
var first_action : bool = true
var can_move : bool = false
var clickable : bool = false
var click_stuck : bool = false
var show_label : bool = false

onready var tilemap : TileMap = get_tree().get_nodes_in_group("nav")[0]
onready var pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]
onready var floodfill = get_tree().get_nodes_in_group("floodfill")[0]
onready var level = get_tree().get_nodes_in_group("level")[0]

var outline_color : Color setget , get_outline_color

export (String) var CLASS
export(int, 0, 100, 1) var cost = 10
export(int, -20, 20, 1) var initiative
export(int, 1 , 300) var base_health_points = 80
#export(int, 0, 20) var base_movement_points = 3
export(int, 0, 10) var base_energy = 3
export(int, 0, 10) var base_stamina = 3
export(String, MULTILINE) var description

var max_health_points : int
var current_health_points : int
var bonus_health_points : int = 0  #given by items

var max_energy : int
var current_energy : int 
var bonus_energy : int = 0

var max_stamina : int
var current_stamina : int
var bonus_stamina : int = 0

var current_range : int = 0

var spells := []
var cooldowns := {} #  {"spell_name" = 0 , ... }


#variables used for buffs/debuffs
var current_buffs := {} #keys = name, values = buff description

var health_points_modif : int = 0
var energy_modif : int = 0 setget add_energy
var stamina_modif : int = 0 setget add_stamina
var range_modif : int = 0

var damage_input_coef_modif : float = 1.0
var damage_input_flat_modif : int = 0
var damage_output_coef_modif : float = 1.0
var damage_output_flat_modif : int = 0

var healing_input_coef_modif : float = 1.0
var healing_input_flat_modif : int = 0
var healing_output_coef_modif : float = 1.0
var healing_output_flat_modif : int = 0

var crit_chance_bonus : float = 0.0

var invulnerable : bool = false
var avoid_next_damage : int = 0 #works like tokens

var shadow_actor : Actor = null #used for sacrifice

var reflection_coef : float = 0.0 #will reduce damage, not lethal
var spine : int = 0 #will not affect damage, lethal

var jinx : bool = false #any random number will be minimum
var third_eye : bool = false #any random number will be maximum

var frozen : bool = false #movement costs 2 energy
var entangled : bool = false #cannot use energy to move


onready var spells_node : Node = $Spells
onready var items_node : Node = $Items

#damage and healing type output modifiers
var damage_type_modif : Dictionary = {
	"Magic": {"Coef" : 1.00, "Flat" : 0.00} ,
	"Physic": {"Coef" : 1.00, "Flat" : 0.00} #,
	#"Psychic": {"Coef" : 1.00, "Flat" : 0.00}
}

#damage type input modifiers
var resistances : Dictionary = {
	"Magic": {"Coef" : 1.00, "Flat" : 0.00} ,
	"Physic": {"Coef" : 1.00, "Flat" : 0.00} #,
	#"Psychic": {"Coef" : 1.00, "Flat" : 0.00}
}

#healing type modifiers
var sensibility : Dictionary = {
	"Magic": {"Coef" : 1.00, "Flat" : 0.00} ,
	"Physic": {"Coef" : 1.00, "Flat" : 0.00} #,
	#"Psychic": {"Coef" : 1.00, "Flat" : 0.00}
}

var moving := false

var is_invisible : bool = false

var rooted : bool = false #can't be moved by spells

var real_position = position setget , get_real_position

#onready var mouse_detector = $Position2D/TextureRect
onready var label = $TextureLabel/TextureLabel
onready var sprite : AnimatedSprite = $AnimatedSprite
onready var ftmanager = $FTManager

#onready var tilemap = get_tree().get_nodes_in_group("nav")[0]

static func get_buff_from_name(buff_name : String) -> Buff :
	var new_buff = load(str(BUFFS_PATH+buff_name+".tscn")).instance()
	return new_buff


func set_ring_color(color : Color) -> void:
	if has_node("Ring"):
		$Ring.modulate = color

#func add_energy(amount : int) -> void:
#	ftmanager.show_value(amount, "", "energy")
#	energy_modif += amount


func add_energy(amount : int) -> void:
	ftmanager.show_value(amount, "", "energy_points")
	energy_modif += amount
	current_energy += amount


func add_stamina(amount : int) -> void:
	ftmanager.show_value(amount, "" , "stamina_points")
	stamina_modif += amount
	current_stamina += amount


func _ready():
	#var i : int = 0
	for spell in spells:
		cooldowns[spell] = 0
	
# warning-ignore:return_value_discarded
	self.connect("mouse_entered", self, "_on_mouse_entered")
# warning-ignore:return_value_discarded
	self.connect("mouse_exited", self, "_on_mouse_exited")


func initialize_actor() -> void:
	max_health_points = base_health_points + bonus_health_points
	current_health_points = max_health_points
	
	#max_energy = base_energy + bonus_energy
	#current_energy = base_energy + bonus_energy
	
	max_energy = base_energy + bonus_energy
	current_energy = max_energy
	
	max_stamina = base_stamina + bonus_stamina
	current_stamina = max_stamina

func get_cell() -> Vector2:
	return tilemap.world_to_map(position)


func _summon(_spell_name):
	pass


func die():
	dead = true
	for puppet_name in puppets:
		for _puppet in puppets[puppet_name]:
			if _puppet != null and is_instance_valid(_puppet):
				_puppet.die()
	if has_node("ActorAnimation"):
		if is_multiplayer:
			get_node("ActorAnimation").rpc("r_play", "died")
		else:
			get_node("ActorAnimation").r_play("died")
		yield(get_node("ActorAnimation"), "animation_finished")
	make_visible(false)
	emit_signal("died", self)


func _take_damage(_base_damage : Array) -> Array:
	#to be overriden by subclass
	return _base_damage


remotesync func take_damage(_base_damage : Array, caster_path : NodePath ,lethality : bool = true, send_signal : bool = true): #damage = [amount : int, damage_type : string]
	#label.show_label()
	
	var caster = get_node(caster_path)
	
	var base_damage
	base_damage = _take_damage(_base_damage)
	
	if shadow_actor != null and is_instance_valid(shadow_actor) and shadow_actor != self:
		if is_multiplayer and is_network_master() :
			shadow_actor.rpc("take_damage", base_damage, caster_path, lethality, send_signal) 
		elif not is_multiplayer:
			shadow_actor.take_damage(base_damage, caster_path, lethality, send_signal)
		return
		
		
	if invulnerable:
		return
		
	var damage
	if not base_damage[1] == "":
		damage = base_damage[0] * resistances[base_damage[1]]["Coef"] + resistances[base_damage[1]]["Flat"]
	else:
		damage= base_damage[0]
		
	var real_damage = int(damage * damage_input_coef_modif) + damage_input_flat_modif
	
	
	if reflection_coef:
		var reflection = real_damage * abs(reflection_coef)
		real_damage -= reflection
		if not is_multiplayer:
			caster.take_damage([reflection, base_damage[1]], self.get_path(), false, true)
		elif is_network_master():
			caster.rpc("take_damage", [reflection, base_damage[1]], self.get_path(), false, true)
		
	if spine:
		if not is_multiplayer:
			caster.take_damage([spine, "Physic"], self.get_path(), true, true)
		elif is_network_master():
			caster.rpc("take_damage", [spine, "Physic"], self.get_path(), true, true)
	
	real_damage = max(0, real_damage)
	
	if avoid_next_damage:
		real_damage = 0
		avoid_next_damage -= 1
		emit_signal("damage_prevented")
		
	current_health_points -= real_damage
	
	if not is_multiplayer or is_network_master():
		CombatPrinter.print_new_line([str(self.name), " took ", str(real_damage), " ", base_damage[1], " damage. (", damage, "*" , damage_input_coef_modif, "+" , damage_input_flat_modif])
	ftmanager.show_value(real_damage, base_damage[1], "damage")
	if real_damage > 0:
		if has_node("ActorAnimation"):
			if is_multiplayer:
				get_node("ActorAnimation").rpc("r_play", "damage_taken")
			else:
				get_node("ActorAnimation").r_play("damage_taken")
		
		if send_signal:
			emit_signal("damage_taken")
			
	if current_health_points <= 0 :
		if lethality:
			die()
		else:
			current_health_points = 1


remotesync func heal(base_healing : Array): #healing = [amount : int, healing_type : string]
	
	var healing
	if not base_healing[1] == "":
		healing = base_healing[0] * sensibility[base_healing[1]]["Coef"] + sensibility[base_healing[1]]["Flat"]
	else:
		healing = base_healing[0]
		
	var real_healing = int(healing * healing_input_coef_modif) + healing_input_flat_modif
	real_healing = max(real_healing, 0)
	if real_healing > max_health_points - current_health_points and max_health_points-current_health_points >= 0:
		real_healing = max_health_points - current_health_points
	elif max_health_points - current_health_points < 0:
		real_healing = 0
	current_health_points += real_healing
	
	CombatPrinter.print_new_line([str(self.name), " healed ", str(real_healing), " ", base_healing[1], " damage. (", healing, "*" , healing_input_coef_modif, "+" , healing_input_flat_modif])
	ftmanager.show_value(real_healing, base_healing[1], "healing")
	
	if real_healing > 0:
		if has_node("ActorAnimation"):
			if is_multiplayer:
				get_node("ActorAnimation").rpc("r_play", "healed")
			else:
				get_node("ActorAnimation").r_play("healed")
		
		emit_signal("heal_received", [real_healing])


remotesync func add_buff(buff_name : String, caster_node_path, critical : bool = false) -> Buff :
	
	var new_buff = get_buff_from_name(buff_name)
	
	var caster = get_node(caster_node_path)
	
	print(caster)
	
	new_buff.set_caster(caster)
	new_buff.singleplayer = not is_multiplayer
	
	new_buff.critical = critical
	
	new_buff._initialize_buff(self)
	#can be used to set variables before trying to apply the buff
	
	if new_buff.apply_mode == Buff.APPLY_MODE.CUSTOM and new_buff._get_custom_apply():
		self.connect(new_buff._get_custom_apply(), new_buff, "on_apply_signal")
	if new_buff.remove_mode == Buff.REMOVE_MODE.CUSTOM and new_buff._get_custom_remove():
		self.connect(new_buff._get_custom_remove(), new_buff, "on_remove_signal")
	
	if current_buffs.has(buff_name):
		var buff_array = current_buffs[buff_name]
		match new_buff.stack_mode:
			Buff.STACK_MODE.ADD :
				if buff_array.size() >= new_buff.max_stack:
					new_buff.queue_free()
					return null
				
				new_buff.set_target(self)
				self.get_node("Buffs").add_child(new_buff, true)
				buff_array.append(new_buff)
				
				if new_buff.apply_mode == Buff.APPLY_MODE.ON_ADD:
					new_buff.apply_buff(self)
				
				return new_buff
				
			Buff.STACK_MODE.REFRESH :
				if buff_array[0] != null and is_instance_valid(buff_array[0]):
					buff_array[0].turns = new_buff.turns
					new_buff.queue_free()
					return null
				
			Buff.STACK_MODE.ADD_REFRESH :
				for _buff in buff_array :
					_buff.turns = new_buff.turns
					
				if buff_array.size() >= new_buff.max_stack:
					new_buff.queue_free()
					return null
					
				new_buff.set_target(self)
				self.get_node("Buffs").add_child(new_buff)
				buff_array.append(new_buff)
				
				if new_buff.apply_mode == Buff.APPLY_MODE.ON_ADD:
					new_buff.apply_buff(self)
				
				
				for _buff in buff_array :
					_buff.turns = new_buff.turns
					
			Buff.STACK_MODE.NO_STACK :
				new_buff.queue_free()
				return null
	
	else:
		new_buff.set_target(self)
		self.get_node("Buffs").add_child(new_buff)
		if new_buff.apply_mode == Buff.APPLY_MODE.ON_ADD:
			new_buff.apply_buff(self)

		

	current_buffs[buff_name] = [new_buff]
	return new_buff


remotesync func make_visible(_visible : bool) -> void:
	if is_multiplayer:
		if not self.is_network_master():
			self.visible = _visible
		elif self.is_network_master():
			modulate = Color(1.0,1.0,1.0,1.0) if _visible else Color(1.0,1.0,1.0,0.4)
	else:
		if team == TEAMS.CLIENT:
			visible = _visible
		else:
			modulate = Color(1.0,1.0,1.0,1.0) if _visible else Color(1.0,1.0,1.0,0.4)
	
	self.is_invisible = not _visible
	
	if _visible:
		for area in get_overlapping_areas():
			if area.get_parent().has_method("make_transparent"):
				area.get_parent().make_transparent(true)
	else:
		for area in get_overlapping_areas():
			if area.get_parent().has_method("make_transparent"):
				for _player in area.get_overlapping_areas():
					if not _player.is_invisible:
						#if there is at least one visible player in the area:
						return
					if is_multiplayer:
						if _player.is_invisible:
							if _player.is_network_master():
								return
							else:
								continue
					else:
						if _player.is_invisible:
							if _player.team == TEAMS.SERVER:
								return
							else:
								continue
				
						
				area.get_parent().make_transparent(false)
						
	pass


func on_critical_hit() -> void:
	ftmanager.show_value("!", "", "crit")


func _on_mouse_entered():
	clickable = true
	if click_stuck:
		return
	show_label = true
	#print("mouse entered")


func _on_mouse_exited():
	clickable = false
	if click_stuck:
		return
	show_label = false
	#print("mouse exited")


func _process(_delta):
	label.set_text((str(current_health_points) + "/" + str(max_health_points)))
	label.visible = show_label
#	if clickable:
#		if Input.is_action_pressed("mouse_left_click") :
#			emit_signal("actor_pressed", self)
#		if Input.is_action_just_pressed("mouse_right_click"):
#			show_label = not click_stuck
#			click_stuck = not click_stuck

func _input(event):
	if clickable:
		if Input.is_action_pressed("mouse_left_click") :
			emit_signal("actor_pressed", self)
		if Input.is_action_just_pressed("mouse_right_click"):
			show_label = not click_stuck
			click_stuck = not click_stuck

remotesync func _raise() -> void:
	self.raise()


func get_real_position():
	real_position = position
	return real_position


func get_outline_color():
	#print("Outline_color requested") #: sprite valid : " , (not sprite == null))
	
	if sprite == null or not is_instance_valid(sprite):
		return null
		
	return sprite.material.get_shader_param("line_color")

