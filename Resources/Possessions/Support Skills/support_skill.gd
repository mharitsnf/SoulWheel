extends Possession


# One phase only, all info regarding the arrow.
export(Dictionary) var pattern

# One phase only, all info regarding the area
export(Dictionary) var area_pattern

# Script that handles the behavior of the attack and defend arrows.
export(GDScript) var behaviors


func _init():
	._init()
	type = Types.SUPPORT_SKILL
