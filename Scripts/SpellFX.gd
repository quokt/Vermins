extends Node2D
class_name SpellFX

signal animation_ended

func start_animation(type : String = ""):
	_start_animation(type)
	$AnimationPlayer.play("Spell")

func _start_animation(type : String):
	pass


func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("animation_ended")
