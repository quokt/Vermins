extends Node

#Dictionary model : {
#	"actor1_class" : {
#		"items" : ["item1", "item2"] ,
#		"spells" : ["spell1" , "spell2"]
#	} ,
#	"actor2_class : {
#		"items" : ["item1"],
#		"spells" : ["spell1", "spell2"]
#}
var player_team : Dictionary = {
	
}

func save(variable):
	var save_game = File.new()
	save_game.open("user://game_data.save", File.WRITE)
	
	var save_dict = {
		"player_team" : player_team
	}
	return save_dict
	
	
