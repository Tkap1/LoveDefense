extends Node
class_name WaveManager

signal spawn(enemy)
signal win
signal wave_changed(wave_index)


var game_state : Dictionary
var wave_template : Dictionary
var wave_to_win := 50
var wave_index := 1
var highest_completed_wave = 0 setget set_highest_completed_wave
var waves := []

func init(_game_state : Dictionary, _wave_template : Dictionary, _wave_to_win := wave_to_win) -> void:
	
	game_state = _game_state
	wave_template = _wave_template
	wave_to_win = _wave_to_win

	
func start():
	
	var wave = create_wave(wave_index)
	waves.append(wave)
	wave_index += 1
	emit_signal("wave_changed", wave_index)
	
	var timer = Utils.add_timer(self, wave.spawn_delay, true, false)
	timer.connect("timeout", self, "spawn_enemy", [wave, timer])
	
	
func spawn_enemy(wave : Dictionary, timer : Timer) -> void:
	
	emit_signal("spawn", wave)
	wave.spawns += 1
	if wave.spawns == wave.spawn_amount:
		timer.stop()
		timer.queue_free()
		wave.finished_spawning = true
	
	
	
func create_wave(_wave_index : int) -> Dictionary:

	var temp_template = wave_template.duplicate(true)
	temp_template.erase("default")
	var keys = temp_template.keys()
	keys.invert()
	var choosen := []
	
	for key in keys:
		if _wave_index % key == 0:
			choosen.append(key)
			if temp_template[key].exclusive:
				break
				
	if choosen.size() == 0:
		choosen.append("default")
		
	var spawn_delays := []
	var spawn_amounts := []
	for key in choosen:
		var data = wave_template[key]
		spawn_delays.append(data.spawn_delay)
		spawn_amounts.append(data.spawn_amount)
		
	spawn_delays.sort_custom(self, "sort")
	spawn_amounts.sort_custom(self, "sort")
	var spawn_delay = spawn_delays.pop_back()[0]
	var spawn_amount = spawn_amounts.pop_back()[0]
	
	var types = []
	for key in choosen:
		if wave_template[key].type != "normal":
			types.append(wave_template[key].type)
	
	var wave = {
		"level": _wave_index,
		"spawn_delay": spawn_delay,
		"spawn_amount": spawn_amount,
		"spawns": 0,
		"types": types,
		"finished_spawning": false,
	}
	return wave
	
	
	
func sort(a, b):
	
	if a[1] < b[1]:
		return true
	return false
	
	
func set_highest_completed_wave(_highest_completed_wave):
	
	highest_completed_wave = _highest_completed_wave
	
	if highest_completed_wave == wave_to_win:
		emit_signal("win")