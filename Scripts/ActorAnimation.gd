extends AnimationPlayer
 
var spell_cast : Dictionary = {
	min_scale = Vector2(1.0, 1.0) ,
	max_scale = Vector2(1.4, 1.4) ,
	delay = 0.18 ,
	amount = 3
}

var damage_taken : Dictionary = {
	delay = 0.12 ,
	amount = 4
}

var healed : Dictionary = {
	base_color = Color.white,
	color = Color.greenyellow ,
	delay = 0.2 ,
	amount = 1
}


func _ready() -> void:
	
	root_node = get_parent().get_node("AnimatedSprite").get_path()
	
	add_spell_cast_anim()
	add_take_damage_anim()
	add_healed_anim()
	add_died_anim()


func add_died_anim() -> void:
	var animation = Animation.new()
	animation.length = 2.6
	
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:modulate")
	animation.track_insert_key(track_index, 0, Color.white)
	animation.track_insert_key(track_index, 1.7, Color.red)
	animation.track_insert_key(track_index, 2.5, Color.black)
	
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:scale")
	animation.track_insert_key(track_index, 0, Vector2(0,0))
	animation.track_insert_key(track_index, 0.3, Vector2(1.3, 1.3))
	animation.track_insert_key(track_index, 1.7, Vector2(1.3 ,1.3))
	animation.track_insert_key(track_index, 2.5, Vector2(0.01 ,0.01))
	
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:rotation_degrees")
	animation.track_insert_key(track_index, 0, -360)
	animation.track_insert_key(track_index, 1.7, -360)
	animation.track_insert_key(track_index, 2.5, 360)
	
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:visible")
	animation.track_insert_key(track_index, 0, true)
	animation.track_insert_key(track_index, 0.3, false)
	animation.track_insert_key(track_index, 0.4, true)
	animation.track_insert_key(track_index, 0.6, false)
	animation.track_insert_key(track_index, 0.7, true)
	animation.track_insert_key(track_index, 0.9, false)
	animation.track_insert_key(track_index, 1.0, true)
	animation.track_insert_key(track_index, 1.2, false)
	animation.track_insert_key(track_index, 1.3, true)
	animation.track_insert_key(track_index, 1.5, false)
	animation.track_insert_key(track_index, 1.6, true)
	
	add_animation("died", animation)


func add_healed_anim() -> void:
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:modulate")
	animation.length = (spell_cast.amount * 2 + 2) * spell_cast.delay
	for p in spell_cast.amount :
		var t1 = p * 2 * spell_cast.delay
		var t2 = t1 + spell_cast.delay
		animation.track_insert_key(track_index, t1, healed.base_color)
		animation.track_insert_key(track_index, t2, healed.color)
		if p == spell_cast.amount - 1:
			animation.track_insert_key(track_index, t2+spell_cast.delay, healed.base_color)
			
	add_animation("healed", animation)


func add_spell_cast_anim() -> void:
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:scale")
	animation.length = (spell_cast.amount * 2 + 1) * spell_cast.delay
	for p in spell_cast.amount :
		var t1 = p * 2 * spell_cast.delay
		var t2 = t1 + spell_cast.delay
		animation.track_insert_key(track_index, t1, spell_cast.min_scale)
		animation.track_insert_key(track_index, t2, spell_cast.max_scale)
		if p == spell_cast.amount - 1:
			animation.track_insert_key(track_index, t2+spell_cast.delay, spell_cast.min_scale)

	add_animation("spell_cast", animation)


func add_take_damage_anim() -> void:
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:visible")
	animation.length = (damage_taken.amount * 2 + 1) * damage_taken.delay
	for p in damage_taken.amount :
		var t1 = p * 2 * damage_taken.delay
		var t2 = t1 + damage_taken.delay
		animation.track_insert_key(track_index, t1, true)
		animation.track_insert_key(track_index, t2, false)
		if p == damage_taken.amount - 1:
			animation.track_insert_key(track_index, t2+damage_taken.delay, true)

	add_animation("damage_taken", animation)


remotesync func r_play(anim_name : String) -> void:
	play(anim_name)
	#yield(self,"animation_finished")
	get_node(root_node).visible = true
