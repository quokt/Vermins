extends Node
class_name Buff

enum STACK_MODE {ADD, REFRESH, ADD_REFRESH, NO_STACK}
enum APPLY_MODE {ON_ADD, ON_TARGET_START, ON_TARGET_END, ON_CASTER_START, ON_CASTER_END, CUSTOM}
enum REMOVE_MODE {DEFAULT, CUSTOM}
enum COOLDOWN_MODE {TARGET, CASTER}

onready var level = get_tree().get_nodes_in_group("level")[0]

export (APPLY_MODE) var apply_mode

export(REMOVE_MODE) var remove_mode

export (String) var buff_name
export (String) var buff_id

export (int, -1, 99, 1) var turns

export (COOLDOWN_MODE) var cooldown_mode

export (Texture) var icon

export (String)  var description

export (String, MULTILINE) var base_description

export (String, MULTILINE) var crit_description

export (STACK_MODE) var stack_mode

export(int, 1, 11, 1) var max_stack

var singleplayer : bool = false

var target setget set_target

var caster setget set_caster

var critical : bool = false


remotesync func pass_turn() -> void:
	if turns == -1:
		return
	
	turns -= 1
	
	_pass_turn()
	
	if turns == 0 :
		remove_buff(target)


func _pass_turn() -> void:
	pass


remotesync func add_turn(amount : int) -> void:
	if turns == -1:
		return
	
	turns += amount


func _get_custom_apply() -> String:
	return ""


func _get_custom_remove() -> String:
	return ""


func on_apply_signal(opt_array : Array = []):
	apply_buff(target, opt_array)


func on_remove_signal():
	remove_buff()


func set_target(target_ ) -> void:
	target = target_
	assert(is_instance_valid(target))

func set_caster(caster_ ) -> void:
	caster = caster_
	assert(is_instance_valid(caster))


func apply_buff(_target = target, opt_array : Array = []) -> void:
	description = base_description if not critical else crit_description
	_apply_buff(_target, opt_array)


func remove_buff(_target = target) -> void:
	_remove_buff(_target)
	if _target.current_buffs.has(buff_id):
	
		_target.current_buffs[buff_id].erase(self)
		
		if _target.current_buffs[buff_id].empty():
			_target.current_buffs.erase(buff_id)
		
	queue_free()


func _apply_buff(_target, _opt_array : Array = []) -> void:
	print("Buff \"", buff_name, "\" is empty", " in ", self)
	pass


func _initialize_buff(_target) -> void:
	pass


func _remove_buff(_target) -> void:
	print("Warning : remove_buff func is empty in ", self, " : no effect was removed")
	pass


func summon(pos : Vector2, new_puppet, _caster = caster) -> void:
	level.summon(pos, new_puppet, _caster)


remotesync func _summon(_pos : Vector2) -> void:
	pass


func _ready():
	if not self in get_tree().get_nodes_in_group("buffs"):
		self.add_to_group("buffs")
	if buff_id == "":
		buff_id = buff_name
