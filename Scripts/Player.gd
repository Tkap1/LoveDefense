extends Node2D


signal start_wave
signal hearts_changed
signal start_placing
signal stop_placing
signal tower_selected(tower)
signal tower_unselected
signal player_death


var states = {
	"default":
	{
		"updates": ["wave_input", "select_input"],
		"data": {},
	},
	"place":
	{
		"updates": ["wave_input", "place_input", "update_place"],
		"on_enter": "on_enter_place",
		"on_leave": "on_leave_place",
		"data": {},
	},
	"select":
	{
		"updates": ["wave_input", "select_input", "leave_select_input"],
		"on_enter": "on_enter_select",
		"on_leave": "on_leave_select",
		"draw": true,
		"data": {},
	},
}

var spr_selector
var game_state
var state_manager : StateManager
var hearts := 200.0 setget set_hearts


func _init(_game_state : Dictionary):
	
	game_state = _game_state

	
func _ready():
	
	state_manager = StateManager.new(self, states)
	add_child(state_manager)
	state_manager.set_state("default")
	
	spr_selector = Utils.add_sprite(self, load("res://Assets/selector.tres"), Cfg.tile_size)
	
	
func _physics_process(delta):
	
	state_manager.process(delta)
	spr_selector.position = Utils.tile_center(Utils.pos2tile_pos(get_global_mouse_position()))
	
	
func update_place(state_data : Dictionary, delta):
	
	var place_pos = Utils.pos2tile_pos(get_global_mouse_position())
	var tilemap = game_state.map.tilemap
	var tile = tilemap.get_cellv(tilemap.world_to_map(place_pos))
	var sprite_position = Utils.tile_center(place_pos)
	state_data.tower_sprite.position = sprite_position
	
	var color = Color(1, 1, 1, 0.5) if can_place(place_pos, state_data.tower_key) else Color(1, 0, 0, 0.5)
	state_data.tower_sprite.modulate = color
	
	
func place_input(state_data : Dictionary, delta):
	
	if Input.is_action_just_pressed("left_click"):
		var place_pos = Utils.pos2tile_pos(get_global_mouse_position())
		if can_place(place_pos, state_data.tower_key):
			place(place_pos, state_data.tower_key)
			
	if Input.is_action_just_pressed("ui_cancel"):
		state_manager.set_state("default")
		return "break"


func on_enter_place(state_data : Dictionary) -> void:
	
	state_data.tower_sprite = Utils.add_sprite(self, Refs.tower_data[state_data.tower_key].texture, Cfg.tile_size)
	emit_signal("start_placing")
	
	
func on_leave_place(state_data : Dictionary) -> void:
	
	state_data.tower_sprite.queue_free()
	emit_signal("stop_placing")
	
	
func can_place(_position : Vector2, tower_key : String) -> bool:
	
	if _position in game_state.map.towers:
		return false
		
	if int(hearts) - 1 < Refs.tower_data[tower_key].build_cost:
		return false
	
	var tilemap = game_state.map.tilemap
	var tile_index = tilemap.get_cellv(tilemap.world_to_map(_position))
	
	if tile_index == -1:
		return false
	
	var tile_name = tilemap.tile_set.tile_get_name(tile_index)
	
	return Refs.tile_data[tile_name].buildable
	
	
func place(_position : Vector2, tower_key : String):
	
	var new_tower = Refs.tower_data[tower_key].script.new()
	game_state.map.add_child(new_tower)
	new_tower.init(game_state, Utils.tile_center(_position), tower_key)
	
	game_state.map.towers[_position] = new_tower
	self.hearts -= new_tower.build_cost
	
	game_state.audio.play_dict(Refs.place_tower)
	
	
func wave_input(state_data : Dictionary, delta):
	
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("start_wave")
		
		
func set_hearts(new_hearts):
	
	hearts = new_hearts
	
	if hearts <= 0:
		emit_signal("player_death")
	else:
		emit_signal("hearts_changed", hearts, state_manager.current_state_key == "select")
	
	
	
func select_input(state_data : Dictionary, delta):
	
	if Input.is_action_just_pressed("left_click"):
		var tile_position = Utils.pos2tile_pos(get_global_mouse_position())
		if tile_position in game_state.map.towers:
			state_manager.set_state("select", {"selected_tower": game_state.map.towers[tile_position], "tower_position": tile_position})
			
	
func leave_select_input(state_data : Dictionary, delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		state_manager.set_state("default")
			
			
func on_enter_select(state_data : Dictionary):
	
	emit_signal("tower_selected", state_data.selected_tower)
	
	
func on_leave_select(state_data : Dictionary):
	
	state_data.erase("selected_tower")
	update()
	emit_signal("tower_unselected")
	
	
func _draw():
	
	var state_data = state_manager.current_state.data
	var tower = state_data.get("selected_tower", null)
	
	if tower:
		draw_circle(tower.position, tower.attack_range, Color(0, 0, 0, 0.5))