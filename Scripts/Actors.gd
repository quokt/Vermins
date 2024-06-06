extends YSort


func sort_actors(a : Actor, b : Actor) -> bool :
	#if a.initiative == b.initiative:
	#	return bool(randi() % 2)
	#else:
		return a.initiative > b.initiative
