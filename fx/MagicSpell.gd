extends Node2D

signal animation_ended

func start_animation(spell_type : String = ""):
	$AnimationPlayer.play("Spell")

func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("animation_ended")
