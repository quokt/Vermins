extends Resource
class_name SpellResource

enum ANIM_MODE {ORIGIN, TARGETS, CASTER}
enum CAST_MODE {ORIGIN, CUSTOM}
enum CELL_MODE {EMPTY, FULL, BOTH}
enum AOE_MODE {DEFAULT, CROSS, DIAGONAL, STAR, LINE_PARALLEL, LINE_PERPENDICULAR, SQUARE}
enum RANGE_MODE {DEFAULT, LINE, DIAGONAL, STAR}
enum SPELL_TYPE {PHYSIC, MAGIC}
enum TARGETS {ALL, ENEMIES, ALLIES, CASTER, ALL_NO_CASTER, EMPTY}

export (bool) var base_spell = false

export(int, FLAGS, "Attack", "Heal", "Jump", "Buff") var spell_effects = 0

#hard coded flags detector -> key = effect, value = true/false
var selected_flags: Dictionary = {
	attack = spell_effects in [1, 3, 5, 7, 9, 11, 13, 15],
	heal = spell_effects in [2, 3, 6, 7, 10, 11, 14, 15],
	jump = spell_effects in [4, 5, 6, 7, 12, 13, 14, 15],
	buff = spell_effects in [8, 9, 10, 11, 12, 13, 14, 15]
}

export (int, 0, 50, 1) var min_range
export (int, 0 , 50 , 1) var max_range

export (Texture) var icon

export (String) var animation

export (String) var spell_name
export (String) var spell_ID
export (String) var character
export (String, MULTILINE) var description
export (String) var critical_effect

export (int, 0, 30, 1) var cost
#export (int, 0, 10, 1) var bonus_energy

export (ANIM_MODE) var anim_mode
export (CAST_MODE) var cast_mode
export (CELL_MODE) var cell_mode

export (int, 0, 12) var energy_cost

export (bool) var sight_needed
export (bool) var range_modif
export (RANGE_MODE) var range_mode = RANGE_MODE.DEFAULT

export(int, 0, 10, 1) var max_per_turn
export (int, 0 , 99, 1) var cooldown

export (int, 0, 99, 1) var min_power
export (int, 0, 99, 1) var max_power

export (int, 0, 99, 1) var crit_min_power
export (int, 0, 99, 1) var crit_max_power

export (float, 0, 1) var crit_chance = 0.1

export (SPELL_TYPE) var spell_type

export (int, 0, 100, 1) var aoe
export (AOE_MODE) var aoe_mode

export (String) var buff_name
export (TARGETS) var buff_targets

export (TARGETS) var ai_targets = TARGETS.ENEMIES

var effects : Array = []
