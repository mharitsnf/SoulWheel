extends Character
class_name Player


export var player_data_model : Resource
export(PackedScene) var skill_hud : PackedScene

var rng = RandomNumberGenerator.new()
var chosen_skill : AttackSkill = null

var skill_hud_ins : Control = null

onready var root : Node = get_parent().get_parent()

signal skill_button_pressed


func _ready():
	assert(player_data_model)
	assert(player_data_model is PlayerDataModel)
	
	Globals.player = self
	player_data_model.current_health = player_data_model.max_health
	
	rng.randomize()
	
	if Globals.current_area == 1 and Globals.current_round == 1:
		_put_card_on_deck(Globals.skill_resource_paths.basic)
		_put_card_on_deck(Globals.skill_resource_paths.double)
		_put_card_on_deck(Globals.skill_resource_paths.trinity)


func take_damage(damage):
	var new_health = player_data_model.current_health - damage
	player_data_model.current_health = max(0, new_health)
	
	if new_health <= 0:
		return true
	
	return false


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
		
		# TODO: Add transition
		var defeateds = _check_result()
		for enemy in defeateds:
			yield(_defeat_enemy(enemy), "completed")
		
		Globals.saved_arrow = []
		
		if turn_manager.get_child_count() == 1 and turn_manager.get_child(0) == self:
			yield(get_tree().create_timer(0.5), "timeout")
			yield(_destroy_wheel(), "completed")
			_end_turn()
			return true
		
		yield(get_tree().create_timer(0.5), "timeout")
		yield(_destroy_wheel(), "completed")
		yield(get_tree().create_timer(0.5), "timeout")
	
	_end_turn()
	return false


func _check_result():
	var defeated_enemies = []
	
	if !Globals.saved_areas.empty() and !Globals.saved_arrow.empty():
		for enemy in Globals.saved_areas:
			for arrow in Globals.saved_arrow:
				var arrow_angle : Vector2 = Globals.generate_angles(arrow.rot_angle, arrow.thickness)

				for area in enemy.dm.soul_areas:
					var area_angle : Vector2 = Globals.generate_angles(area.rot_angle, area.thickness)

					if _is_hit(arrow_angle, area_angle):
						var is_defeated = enemy.node.take_damage(chosen_skill.damage)
						print(enemy.node, " hit! health: ", enemy.node.current_health)
						
						if is_defeated and !defeated_enemies.has(enemy): defeated_enemies.append(enemy)
						
	return defeated_enemies


func _defeat_enemy(enemy_data):
	Globals.saved_areas.erase(enemy_data)
	enemy_data.node.queue_free()
	yield(get_tree(), "idle_frame")


func _end_turn():
	Globals.saved_areas = []
	
	._end_turn()


func _put_card_on_deck(path):
	Globals.skill_deck.append(Globals.attack_loader(path))


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
