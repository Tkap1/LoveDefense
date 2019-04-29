extends Control


signal game_over


var game_state = {}


onready var grid_container = find_node("GridContainer")
onready var heart_label = find_node("HeartLabel")
onready var panel = find_node("Panel")
onready var upgrade_button = find_node("UpgradeButton")
onready var sell_button = find_node("SellButton")
onready var damage_label = find_node("DamageLabel")
onready var speed_label = find_node("SpeedLabel")
onready var range_label = find_node("RangeLabel")
onready var cancel_label = find_node("CancelLabel")
onready var start_wave_button = find_node("StartWaveButton")
onready var arrow_indicator = find_node("ArrowIndicator")
onready var game_win_ui = find_node("GameWinUI")
onready var continue_button = find_node("ContinueButton")
onready var exit_button = find_node("ExitButton")


func _ready():
	
	game_state.resetting = false
	
	game_state.map = load("res://Scenes/Map1.tscn").instance()
	add_child(game_state.map)
	
	game_state.player = load("res://Scripts/Player.gd").new(game_state)
	add_child(game_state.player)
	game_state.player.connect("hearts_changed", self, "on_player_hearts_changed")
	game_state.player.connect("start_placing", self, "on_player_start_placing")
	game_state.player.connect("stop_placing", self, "on_player_stop_placing")
	game_state.player.connect("tower_selected", self, "on_player_tower_selected")
	game_state.player.connect("tower_unselected", self, "on_player_tower_unselected")
	game_state.player.connect("player_death", self, "on_player_death")
	
	game_state.map.connect("enemy_reached_end", self, "on_enemy_reached_end")
	
	game_state.map.init(game_state)
	
	for tower_key in Refs.tower_data:
		
		var data = Refs.tower_data[tower_key]
		var button = TextureButton.new()
		grid_container.add_child(button)
		button.texture_normal = data.texture
		button.size_flags_horizontal = button.SIZE_EXPAND_FILL
		button.connect("pressed", self, "on_tower_button_pressed", [tower_key])
		
	on_player_hearts_changed(game_state.player.hearts, false)
	
	upgrade_button.connect("pressed", self, "on_upgrade_pressed")
	sell_button.connect("pressed", self, "on_sell_pressed")
	start_wave_button.connect("pressed", self, "on_start_wave_pressed")
	game_state.map.wave_manager.connect("wave_changed", self, "on_wave_changed")
	game_state.map.wave_manager.connect("win", self, "on_game_win")
	
	continue_button.connect("pressed", self, "on_game_win_continue_pressed")
	exit_button.connect("pressed", self, "on_game_win_exit_pressed")
	
	game_state.audio = AudioManager.new(false, 20)
	add_child(game_state.audio)
	
	game_state.music = AudioStreamPlayer.new()
	add_child(game_state.music)
	game_state.music.pause_mode = PAUSE_MODE_PROCESS
	game_state.music.stream = Refs.music.file
	game_state.music.volume_db = Refs.music.volume
	game_state.music.pitch_scale = Refs.music.pitch
	game_state.music.play()
	
	var y = Global.SafeYield.new(self)
	y.wait_timer(5.0)
	yield(y, "done")
	arrow_indicator.hide()
	
	
func on_wave_changed(wave_index : int):
	
	start_wave_button.text = "START WAVE %s" % wave_index
	
	
func on_start_wave_pressed():
	
	game_state.player.emit_signal("start_wave")
		
		
func on_tower_button_pressed(tower_key):
	
	game_state.player.state_manager.set_state("place", {"tower_key": tower_key})
		

func on_player_hearts_changed(hearts : float, selecting_state : bool):
	
	heart_label.text = str(int(hearts))
	
	if selecting_state:
		var state_data = game_state.player.state_manager.current_state.data
		var tower_upgrade_cost = state_data.selected_tower.upgrade_cost
		
		if int(game_state.player.hearts) - 1 >= tower_upgrade_cost:
			upgrade_button.disabled = false
		else:
			upgrade_button.disabled = true
	
	
	
func on_player_start_placing():
	
	panel.hide()
	cancel_label.show()
	
	
func on_player_stop_placing():
	
	panel.show()
	cancel_label.hide()
	
	
func on_player_tower_selected(tower):
	
	upgrade_button.text = "UPGRADE (%s)" % tower.upgrade_cost
	sell_button.text = "SELL (%s)" % tower.sell_reward
	if int(game_state.player.hearts) - 1 >= tower.upgrade_cost:
		upgrade_button.disabled = false
		
	sell_button.disabled = false
	
	damage_label.text = str(tower.damage)
	speed_label.text = str(int(1.0 / tower.attack_delay * 100.0))
	range_label.text = str(int(tower.attack_range))
	cancel_label.show()
	
	
func on_player_tower_unselected():
	
	upgrade_button.text = "UPGRADE"
	sell_button.text = "SELL"
	upgrade_button.disabled = true
	sell_button.disabled = true
	cancel_label.hide()
	
	
func on_upgrade_pressed():
	
	var state_data = game_state.player.state_manager.current_state.data
	var tower_upgrade_cost = state_data.selected_tower.upgrade_cost
	if int(game_state.player.hearts) - 1 >= tower_upgrade_cost:
		
		# Upgrade the tower
		state_data.selected_tower.upgrade()
		
		# Update the upgrade button text to match new value
		on_player_tower_selected(state_data.selected_tower)
		
		# Substract the hearts now so the upgrade button updates to reflect if we have enough hearts for the next upgrade
		game_state.player.hearts -= tower_upgrade_cost
	
	
func on_sell_pressed():
	
	var state_data = game_state.player.state_manager.current_state.data
	var selected_tower = state_data.selected_tower
	
	game_state.player.hearts += selected_tower.sell_reward
	
	game_state.map.towers.erase(state_data.tower_position)
	selected_tower.queue_free()
	
	game_state.player.state_manager.set_state("default")
	game_state.player.update()
	
	
func on_enemy_reached_end(hearts_taken):
	
	game_state.player.hearts -= hearts_taken
	
	
func on_player_death():
	
	if not game_state.resetting:
		game_state.resetting = true
		heart_label.text = "0"
		
		yield(get_tree().create_timer(1.0), "timeout")
		emit_signal("game_over")

		
func on_game_win():
	
	get_tree().paused = true
	game_win_ui.show()
	
	
func on_game_win_continue_pressed():
	
	get_tree().paused = false
	game_win_ui.hide()
	
	
func on_game_win_exit_pressed():
	
	get_tree().paused = false
	emit_signal("game_over")