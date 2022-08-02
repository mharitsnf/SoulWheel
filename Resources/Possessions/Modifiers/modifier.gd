extends Possession


# List of modifications to be applied.
# Array of dictionary.
# {"key": "...", "amount": "...", "operator": "...", "relative_idx": "..."}
export(Array) var modifications


func _init():
	._init()
	type = Types.MODIFIER
