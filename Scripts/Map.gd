extends Node


signal enemy_reached_end(hearts_taken)


# Keeping track of WHERE towers have been placed, to avoid placing towers on top of one another.
var towers = {}

var wave_manager
var game_state : Dictionary

onready var tilemap = find_node("TileMap")
onready var navigation = find_node("Navigation2D")
onready var spawn_position = find_node("SpawnPosition").position
onready var end_position = find_node("EndPosition").position
onready var y_sort = find_node("YSort")


func _ready():
	
	var wave_template := {
		"default":
		{
			"type": "normal",
			"spawn_amount": [20, 0],
			"spawn_delay": [0.25, 0],
		},
		6:
		{
			"type": "flyer",
			"spawn_amount": [20, 0],
			"spawn_delay": [0.25, 0],
			"exclusive": false,
		},
		4:
		{
			"type": "fast",
			"spawn_amount": [40, 1],
			"spawn_delay": [0.1, 1],
			"exclusive": false,
		},
		5:
		{
			"type": "durable",
			"spawn_amount": [5, 2],
			"spawn_delay": [1.0, 2],
			"exclusive": false,
		},
		10:
		{
			"type": "boss",
			"spawn_amount": [1, 10],
			"spawn_delay": [1.0, 10],
			"exclusive": true,
		},
	}
	
	wave_manager = WaveManager.new()
	add_child(wave_manager)
	wave_manager.init(game_state, wave_template, 50)
	wave_manager.connect("spawn", self, "on_wave_spawn")

func init(_game_state : Dictionary) -> void:
	
	game_state = _game_state
	game_state.player.connect("start_wave", self, "start_wave")
	
	
func start_wave() -> void:
	
	wave_manager.start()
	
	
func on_wave_spawn(wave : Dictionary) -> void:
	
	var enemy = Refs.enemy_script.new()
	y_sort.add_child(enemy)
	enemy.init(game_state, game_state.map.spawn_position, wave.level, wave.types)
	enemy.add_to_group("wave%s_enemies" % wave.level)
	enemy.connect("on_death", self, "on_enemy_death")
	enemy.connect("reached_end", self, "on_enemy_reached_end")
	
	
func on_enemy_death(enemy):

	var groups = enemy.get_groups()
	var group = ""
	for temp_group in groups:
		if "wave" in temp_group:
			group = temp_group
			break
			
	enemy.remove_from_group(group)
	
	if get_tree().get_nodes_in_group(group).size() == 0:
		if wave_manager.waves[enemy.level - 1].finished_spawning:
			wave_manager.highest_completed_wave = enemy.level
			
	game_state.player.hearts += enemy.heart_reward
	enemy.queue_free()
	
	var heart_particles = Refs.heart_particles.instance()
	add_child(heart_particles)
	heart_particles.position = enemy.position
	heart_particles.emitting = true
	
	var s_yield = Global.SafeYield.new(self)
	s_yield.wait_timer(heart_particles.lifetime)
	yield(s_yield, "done")
	heart_particles.queue_free()
	
	
func on_enemy_reached_end(enemy):
	
	emit_signal("enemy_reached_end", enemy.hearts_taken)
	
	var groups = enemy.get_groups()
	var group = ""
	for temp_group in groups:
		if "wave" in temp_group:
			group = temp_group
			break
			
	enemy.remove_from_group(group)
	
	if get_tree().get_nodes_in_group(group).size() == 0:
		if wave_manager.waves[enemy.level - 1].finished_spawning:
			wave_manager.highest_completed_wave = enemy.level
	
	enemy.queue_free()