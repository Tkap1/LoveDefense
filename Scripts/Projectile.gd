extends Area2D

enum {HOMING, AIM_ONCE}

var speed := 250.0
var sprite : Sprite
var notifier : VisibilityNotifier2D
var damage := 1
var has_hit := false
var direction := Vector2()
var explodes := false
var penetrates := false
var type := AIM_ONCE
var target = null
var target_ref
var explosion_radius := 96.0
var explosion_damage_multiplier := 0.5
var rotates := false
var debuffs := []

# Whether or not it can collide with enemies that are not its target
var target_only := false

func _ready():

	z_index = 1
	
	sprite = Utils.add_sprite(self, Refs.cannonball, Cfg.tile_size / 2.0)
	
	var collision = CollisionShape2D.new()
	add_child(collision)
	collision.shape = CircleShape2D.new()
	collision.shape.radius = Cfg.tile_size.x * sprite.scale.x
	
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	set_collision_mask_bit(Cfg.layer_enemy, true)
	
	
	notifier = VisibilityNotifier2D.new()
	add_child(notifier)
	notifier.connect("screen_exited", self, "queue_free")
	
	connect("area_entered", self, "on_area_entered")
	
	
func init(projectile_data : Dictionary):
	
	position = projectile_data.get("position", position)
	direction = projectile_data.get("direction", direction)
	speed = projectile_data.get("speed", speed)
	damage = projectile_data.get("damage", damage)
	sprite.texture = projectile_data.get("texture", sprite.texture)
	penetrates = projectile_data.get("penetrates", penetrates)
	explodes = projectile_data.get("explodes", explodes)
	type = projectile_data.get("type", type)
	target = projectile_data.get("target", target)
	if target:
		target_ref = weakref(target)
	target_only = projectile_data.get("target_only", target_only)
	explosion_radius = projectile_data.get("explosion_radius", explosion_radius)
	explosion_damage_multiplier = projectile_data.get("explosion_damage_multiplier", explosion_damage_multiplier)
	rotates = projectile_data.get("rotates", rotates)
	debuffs = projectile_data.get("debuffs", debuffs)
	
	
	
func _physics_process(delta):
	
	match(type):
		HOMING:
			if target and target_ref and target_ref.get_ref():
				direction = (target.position - position).normalized()
			position += direction * speed * delta
				
		AIM_ONCE:
			position += direction * speed * delta
			
	if rotates:
		rotation = direction.angle() + PI / 2
	
	
func on_area_entered(area):
	
	if not has_hit:
		if target_ref and target_ref.get_ref() and target_only and area != target:
			return
		area.get_hit(damage)
		
		for debuff in debuffs:
			debuff.func_ref.call_func(area, debuff)
			
		has_hit = true
		set_physics_process(false)
		
		if explodes:
			var explosion_area = Area2D.new()
			add_child(explosion_area)
			explosion_area.set_collision_layer_bit(0, false)
			explosion_area.set_collision_mask_bit(0, false)
			explosion_area.set_collision_mask_bit(Cfg.layer_enemy, true)
			var explosion_collision = CollisionShape2D.new()
			explosion_area.add_child(explosion_collision)
			explosion_collision.shape = CircleShape2D.new()
			explosion_collision.shape.radius = explosion_radius / 2.0
			sprite.hide()
			Utils.add_sprite(self, Refs.explosion, Cfg.tile_size)
			var y = Global.SafeYield.new(self)
			y.wait_timer(0.25)
			yield(y, "done")
			
			for area in explosion_area.get_overlapping_areas():
				if target_ref and target_ref.get_ref() and area == target:
					continue
				area.get_hit(damage * explosion_damage_multiplier)
		
		queue_free()