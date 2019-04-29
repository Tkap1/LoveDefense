extends Node


var enemy_script = preload("res://Scripts/Enemy.gd")
var projectile_script = preload("res://Scripts/Projectile.gd")

var enemy = preload("res://Assets/enemy_ghost.tres")
var enemy_durable = preload("res://Assets/enemy_ghost_durable.tres")
var enemy_flyer = preload("res://Assets/enemy_ghost_flyer.tres")
var enemy_fast = preload("res://Assets/enemy_ghost_fast.tres")
var enemy_boss = preload("res://Assets/enemy_boss.tres")

var heart = preload("res://Assets/heart.tres")
var heart_particles = preload("res://Scenes/HeartParticles.tscn")

# Towers
var machinegun = preload("res://Assets/tower_machinegun.tres")
var explosion = preload("res://Assets/explosion.tres")
var tower_ice = preload("res://Assets/tower_ice.tres")

# Projectiles
var cannonball = preload("res://Assets/projectile_cannonball.tres")
var projectile_machinegun = preload("res://Assets/projectile_machinegun.tres")
var projectile_ice = preload("res://Assets/projectile_ice.tres")


var health_bar_under = preload("res://Assets/Textures/health_bar_under.png")
var health_bar_progress = preload("res://Assets/Textures/health_bar_progress.png")

# Sounds
var music = {
	"file": preload("res://Assets/Sounds/music.ogg"),
	"volume": 5.0,
	"pitch": 1.0,
}

var shoot_cannon = {
	"file": preload("res://Assets/Sounds/shoot_cannon.wav"),
	"volume": -10.0,
	"pitch": 1.0,
}

var shoot_machinegun = {
	"file": preload("res://Assets/Sounds/shoot_machinegun.wav"),
	"volume": -10.0,
	"pitch": 1.0,
}

var shoot_ice = {
	"file": preload("res://Assets/Sounds/shoot_ice.wav"),
	"volume": -15.0,
	"pitch": 1.0,
}

var place_tower = {
	"file": preload("res://Assets/Sounds/place_tower.wav"),
	"volume": -5.0,
	"pitch": 1.0,
}

var upgrade_tower = {
	"file": preload("res://Assets/Sounds/upgrade_tower.wav"),
	"volume": -10.0,
	"pitch": 1.0,
}

var tower_shape

var tower_data := {
	"machinegun":
	{
		"script": preload("res://Scripts/Machinegun.gd"),
		"damage": 5,
		"attack_delay": 0.5,
		"attack_range": 200.0,
		"build_cost": 20,
		"texture": machinegun,
		"rotates": true,
		"shoot_sound": shoot_machinegun,
	},
	"cannon":
	{
		"script": preload("res://Scripts/CannonTower.gd"),
		"damage": 5,
		"attack_delay": 1.0,
		"attack_range": 150.0,
		"build_cost": 20,
		"texture": preload("res://Assets/Textures/tower_cannon.png"),
		"rotates": true,
		"shoot_sound": shoot_cannon,
	},
	"ice":
	{
		"script": preload("res://Scripts/IceTower.gd"),
		"damage": 2,
		"attack_delay": 1.0,
		"attack_range": 150.0,
		"build_cost": 20,
		"texture": tower_ice,
		"rotates": false,
		"shoot_sound": shoot_ice,
	},
}

var tile_data := {
	"grass":
	{
		"buildable": true,
	},
	"dirt":
	{
		"buildable": false,
	},
}


var enemy_modifiers := {
	
	"fast": "apply_fast",
	"flyer": "apply_flyer",
	"durable": "apply_durable",
	"boss": "apply_boss",
	
}


func _ready():
	
	tower_shape = RectangleShape2D.new()
	tower_shape.extents = Cfg.tile_size / 2