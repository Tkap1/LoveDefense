extends Node

const ENEMY_MIN_DISTANCE_TO_END = 16
const ENEMY_BASE_HEALTH := 10

const TOWER_SELL_PERCENT := 0.75
const TOWER_BASE_UPGRADE_COST_PERCENT := 2.0
const TOWER_UPGRADE_COST_MULTIPLIER := 2.0


var tile_size := Vector2(64, 64)

var window := Vector2(1650, 1080)

var layer_enemy := 1
var layer_tower := 2
var layer_projectile := 3

