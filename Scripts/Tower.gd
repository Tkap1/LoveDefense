extends Area2D

var sprite : Sprite
var collision : CollisionShape2D
var game_state
var damage : int
var attack_delay : float
var build_cost : int
var range_area : Area2D
var range_area_collision : CollisionShape2D
var enemies_in_range = []
var attack_timer : Timer
var can_shoot := false
var attack_range : float
var base_attack_range : float
var tower_key : String
var upgrade_cost : int
var sell_reward : int
var total_cost : int
var rotates := false
var shoot_sound = Refs.shoot_cannon

# The enemy we want to shoot
var target

# Upgrade stuff (experimental)
var damage_per_gold : float

func _ready():
	
	collision = CollisionShape2D.new()
	collision.shape = Refs.tower_shape
	
	range_area = Area2D.new()
	add_child(range_area)
	range_area_collision = CollisionShape2D.new()
	range_area_collision.shape = CircleShape2D.new()
	range_area.add_child(range_area_collision)
	
	range_area.set_collision_layer_bit(0, false)
	range_area.set_collision_mask_bit(0, false)
	
	range_area.set_collision_mask_bit(Cfg.layer_enemy, true)
	
	sprite = Sprite.new()
	add_child(sprite)
	
	
func init(_game_state : Dictionary, _position : Vector2, _tower_key : String) -> void:
	
	game_state = _game_state
	position = _position
	
	tower_key = _tower_key
	var data = Refs.tower_data[tower_key]
	damage = data.damage
	attack_delay = data.attack_delay
	build_cost = data.build_cost
	attack_range = data.attack_range
	base_attack_range = attack_range
	range_area_collision.shape.radius = attack_range
	sprite.texture = data.texture
	total_cost = build_cost
	sell_reward = total_cost * Cfg.TOWER_SELL_PERCENT
	upgrade_cost = build_cost * Cfg.TOWER_BASE_UPGRADE_COST_PERCENT
	
	rotates = data.get("rotates", rotates)
	shoot_sound = data.get("shoot_sound", shoot_sound)
	
	damage_per_gold = damage / float(build_cost)
	
	
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	
	range_area.connect("area_entered", self, "on_area_entered")
	range_area.connect("area_exited", self, "on_area_exited")
	
	attack_timer = Utils.add_timer(self, attack_delay, true, false)
	attack_timer.connect("timeout", self, "try_shoot")
	
	
func upgrade():
	
	damage += int(damage_per_gold * upgrade_cost)
	attack_delay *= 0.95
	attack_range += base_attack_range * 0.1
	
	range_area_collision.shape.radius = attack_range
	
	total_cost += upgrade_cost
	sell_reward = total_cost * Cfg.TOWER_SELL_PERCENT
	upgrade_cost = int(upgrade_cost * Cfg.TOWER_UPGRADE_COST_MULTIPLIER)
	
	game_state.audio.play_dict(Refs.upgrade_tower)
	
	
func on_area_entered(area):
	
	enemies_in_range.append(area)
	
	if not target:
		target = area
		if can_shoot:
			shoot()
	
	
func on_area_exited(area):
	
	enemies_in_range.erase(area)
	
	# If the enemy that leaves our range is our current target,
	# our new target will be the oldest enemy that is range
	if area == target:
		if enemies_in_range.size() > 0:
			target = enemies_in_range[0]
		else:
			target = null
			
			
func try_shoot():
	
	if target and not target.alive:
		on_area_exited(target)
	
	if target:
		shoot()
	else:
		can_shoot = true
		
		
func shoot():
	
	if rotates:
		rotation = (target.position - position).angle() + PI / 2.0
	
	can_shoot = false
	attack_timer.start()
	
	# Create projectile
	var new_projectile = Refs.projectile_script.new()
	var projectile_data = get_projectile_data(new_projectile)
	game_state.map.add_child(new_projectile)
	new_projectile.init(projectile_data)
	
	game_state.audio.play_dict(shoot_sound)

	
func get_projectile_data(new_projectile) -> Dictionary:
	return {}