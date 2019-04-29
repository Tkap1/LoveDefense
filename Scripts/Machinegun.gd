extends "res://Scripts/Tower.gd"


func get_projectile_data(new_projectile) -> Dictionary:
	
	var projectile_data = {
		"position": position,
		"damage": damage,
		"speed": 400.0,
		"type": new_projectile.HOMING,
		"target": target,
		"texture": Refs.projectile_machinegun,
		"rotates": true,
	}
	return projectile_data