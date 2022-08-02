extends Resource
class_name Possession


export(String) var name


enum Types {
	ATTACK_SKILL,
	SUPPORT_SKILL,
	MODIFIER
}

var type


func _init():
	resource_local_to_scene = true
