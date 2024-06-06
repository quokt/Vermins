extends Item

var pathfinder = null
var tilemap : TileMap = null

export var damage_coef : float = 0.5

export var damage_type : String = "Magic"

export var lethality : bool = true

func _ready():
	if get_tree().get_nodes_in_group("pathfinder"):
		pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]
	if get_tree().get_nodes_in_group("nav"):
		tilemap = get_tree().get_nodes_in_group("nav")[0]


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	if not pathfinder or not tilemap:
		if get_tree().get_nodes_in_group("pathfinder"):
			pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]
		if get_tree().get_nodes_in_group("nav"):
			tilemap = get_tree().get_nodes_in_group("nav")[0]
	
	for pos in pathfinder.get_neighbors(actor.position, false):
		var cell = tilemap.world_to_map(pos)
		if cell in pathfinder.occupied_cells.keys():
			var damage = opt_array[0]
			var _actor = pathfinder.occupied_cells[cell]
			_actor.rpc("take_damage" , [damage, damage_type], target.get_path(), lethality)
		
	

func _get_custom_apply() -> String:
	return "heal_received"
