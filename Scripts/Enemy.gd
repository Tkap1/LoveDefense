extends Area2D


signal on_death(enemy)
signal reached_end(enemy)

var sprite : Sprite
var max_health : int setget set_max_health
var current_health : int
var heart_reward := 1
var game_state : Dictionary
var alive := true
var level : int
var navigation : Navigation2D
var speed := 100.0
var flyer := false
var hearts_taken : int
var collision : CollisionShape2D
var health_bar : TextureProgress
var debuffs := []


func _ready():
	
	sprite = Utils.add_sprite(self, Refs.enemy, Cfg.tile_size)
	
	collision = CollisionShape2D.new()
	add_child(collision)
	collision.shape = CircleShape2D.new()
	collision.shape.radius = Cfg.tile_size.x / 4
	
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	set_collision_layer_bit(Cfg.layer_enemy, true)
	
	
func init(_game_state : Dictionary, _position : Vector2, _level : int, types : Array):
	
	game_state = _game_state
	position = _position
	level = _level
	
	var temp_level := level - 1
	
	self.max_health = Cfg.ENEMY_BASE_HEALTH + (temp_level * 5) * (1 + temp_level / 10.0)
	
	
	navigation = game_state.map.navigation
	
	for type in types:
		call(Refs.enemy_modifiers[type])
		
		
	# Create health bar
	health_bar = TextureProgress.new()
	add_child(health_bar)
	health_bar.max_value = max_health
	health_bar.min_value = 0
	health_bar.value = health_bar.max_value
	health_bar.step = 1
	health_bar.texture_under = Refs.health_bar_under
	health_bar.texture_progress = Refs.health_bar_progress
	health_bar.rect_position = position - Vector2(48, 250)
	
	
	
func _physics_process(delta):
	
	var direction = get_direction_from_path()
	
	position += direction * speed * delta
	
	if position.distance_to(game_state.map.end_position) < Cfg.ENEMY_MIN_DISTANCE_TO_END:
		emit_signal("reached_end", self)
		alive = false
		set_physics_process(false)
	
	
func get_direction_from_path():
	
	if flyer:
		return (game_state.map.end_position - position).normalized()
		
	else:
		var path = navigation.get_simple_path(position, game_state.map.end_position)
		if path.size() > 1:
			return (path[1] - position).normalized()
	
	
func get_hit(damage : int) -> bool:
	
	if alive:
		current_health -= damage
		health_bar.value = current_health
		if current_health <= 0:
			alive = false
			emit_signal("on_death", self)
		return true
	
	else:
		return false
		
		
func apply_fast():
	
	self.max_health /= 4
	speed = speed * 2.0
	sprite.texture = Refs.enemy_fast
	
	
func apply_durable():
	
	self.max_health = max_health * 5.0
	sprite.texture = Refs.enemy_durable
	sprite.scale *= 1.25
	collision.shape.radius *= 1.25
	
	
func apply_flyer():
	
	self.max_health /= 4
	flyer = true
	speed /= 2.0
	sprite.texture = Refs.enemy_flyer
	
	
func apply_boss():
	
	self.max_health = max_health * 25.0
	sprite.texture = Refs.enemy_boss
	sprite.scale *= 2.0
	collision.shape.radius *= 2.0
	
	
func set_max_health(new_max_health):
	
	max_health = new_max_health
	current_health = max_health
	heart_reward = ceil(max_health / 2.0)
	hearts_taken = ceil(max_health / 2.0)