extends "res://Scripts/Tower.gd"


func get_projectile_data(new_projectile) -> Dictionary:
	
	var projectile_data = {
		"position": position,
		"direction": (target.position - position).normalized(),
		"damage": damage,
		"speed": 250.0,
		"type": new_projectile.AIM_ONCE,
		"explodes": true,
		"target": target,
	}
	return projectile_data
		