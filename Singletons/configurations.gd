extends Node


var wheel = {
	"position": (Vector2(
		ProjectSettings.get("display/window/size/width"),
		ProjectSettings.get("display/window/size/height")
	) / 2) + Vector2(0, 16)
}

var skill_hud = {
	"move_amount": 36,
	"tween_speed": 0.4
}
