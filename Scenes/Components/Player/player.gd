extends Character
class_name Player


export var player_data_model : Resource
export(PackedScene) var wheel : PackedScene
export(PackedScene) var skill_hud : PackedScene

var rng = RandomNumberGenerator.new()
var chosen_skill = null

var skill_hud_ins : Control = null
var wheel_ins : Node2D = null

onready var root : Node = get_parent().get_parent()
onready var turn_manager : Node2D = get_parent()

signal skill_button_pressed


func _ready():
	assert(player_data_model)
	assert(player_data_model is PlayerDataModel)
	Globals.player = self
	rng.randomize()
	
	if Globals.current_area == 1 and Globals.current_round == 1:
		_put_card_on_deck(Globals.skill_resource_paths.attack1)
		_put_card_on_deck(Globals.skill_resource_paths.attack2)


func play_turn():
	print("player playing")
	
	# Skill selection phase
	yield(_summon_skill_hud(), "completed")
	yield(self, "skill_button_pressed") # Wait for player to select a skill
	yield(_destroy_skill_hud(), "completed")
	
	# Soul lock phase
	for character in turn_manager.get_children(): 
		if character is Enemy:
			var current_enemy = Globals.enemy_loader(character)
			yield(_summon_wheel("lock"), "completed")
			yield(wheel_ins.set_enemy(current_enemy), "completed")
			yield(wheel_ins.draw_areas(), "completed")
			yield(wheel_ins.action(), "completed")
			yield(_destroy_wheel(), "completed")
			
			# TODO: Add transition
			yield(get_tree().create_timer(1), "timeout")
	
	# Soul strike phase
	for wheel_phase in chosen_skill.data:
		yield(_summon_wheel("strike"), "completed")
		yield(wheel_ins.set_arrows(wheel_phase), "completed")
		yield(wheel_ins.draw_arrows(), "completed")
		yield(wheel_ins.action(), "completed")
		yield(_destroy_wheel(), "completed")
		
		# TODO: Add transition
		_check_result()
		Globals.saved_arrow = []
		
		yield(get_tree().create_timer(0.5), "timeout")
		
	
	_end_turn()


func _check_result():
	if !Globals.saved_areas.empty() and !Globals.saved_arrow.empty():
		
		for enemy in Globals.saved_areas:
			var hit_count = 0

			for arrow in Globals.saved_arrow:
				var arrow_angle : Vector2 = Globals.generate_angles(arrow.rot_angle, arrow.thickness)

				for area in enemy.soul_areas:
					var area_angle : Vector2 = Globals.generate_angles(area.rot_angle, area.thickness)

					if _is_hit(arrow_angle, area_angle):
						hit_count += 1

			print(enemy.node, " is hit ", hit_count, " times.")


func _is_hit(arrow : Vector2, area : Vector2):
	if arrow.y >= area.x and arrow.x <= area.y:
		return true
	
	return false


func _end_turn():
	Globals.saved_areas = []


func _put_card_on_deck(path):
	Globals.skill_deck.append(Globals.attack_loader(path))


func _summon_wheel(phase):
	wheel_ins = wheel.instance()
	Globals.root.add_child(wheel_ins)
	yield(wheel_ins.initialize(phase), "completed")


func _destroy_wheel():
	yield(wheel_ins.destroy(), "completed")
	wheel_ins = null


func _summon_skill_hud():
	skill_hud_ins = skill_hud.instance()
	Globals.root.add_child(skill_hud_ins)
	yield(skill_hud_ins.initialize(Globals.skill_deck), "completed")


func _destroy_skill_hud():
	yield(skill_hud_ins.destroy(), "completed")
	skill_hud_ins = null


func _on_skill_button_pressed(btn_idx):
	chosen_skill = Globals.skill_deck[btn_idx]
	emit_signal("skill_button_pressed")
