extends Possession


export(Array) var benefits
export(Array) var drawbacks
export(GDScript) var behaviors


func _init():
	._init()
	type = Types.MODIFIER
