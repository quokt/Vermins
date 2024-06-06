extends Spell

var buffs_list = preload("res://Buffs/BuffsList.tres")

#onready var tilemap : TileMap = get_tree().get_nodes_in_group("nav")[0]
#onready var floodfill = get_tree().get_nodes_in_group("floodfill")[0]


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var random_buff = randi() % buffs_list.buffs_list.size()
	var _buff_name = buffs_list.buffs_list[random_buff]
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_add_buff(target, _buff_name, crit)
