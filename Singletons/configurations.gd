extends Node


var wheel = {
	"position": (Vector2(
		ProjectSettings.get("display/window/size/width"),
		ProjectSettings.get("display/window/size/height")
	) / 2) + Vector2(-16 * 1.5, 0)
}

var skill_hud = {
	"move_amount": 36,
	"tween_speed": 0.4
}

var enemy_colors = [
	Color("f4f1de"),
	Color("e07a5f"),
	Color("81b29a"),
	Color("f2cc8f")
]
