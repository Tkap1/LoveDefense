extends "res://Scripts/Tower.gd"


var slow_debuff := {
	"name": "slow",
	"duration": 3.0,
	"func_ref": funcref(self, "apply_slow"),
	"speed_multiplier": 0.5,
	"timer": null,
} 

func get_projectile_data(new_projectile) -> Dictionary:
	
	var projectile_data = {
		"position": position,
		"damage": damage,
		"speed": 300.0,
		"type": new_projectile.AIM_ONCE,
		"target": target,
		"direction": (target.position - position).normalized(),
		"texture": Refs.projectile_ice,
		"rotates": false,
		"debuffs": [slow_debuff],
	}
	return projectile_data
	
	
func apply_slow(enemy, debuff):
	
	
	# If the buff is already applied, refresh the duration
	for temp_debuff in enemy.debuffs:
		if temp_debuff.name == slow_debuff.name:
			temp_debuff.timer.start()
			return
			
	var new_debuff = debuff.duplicate(true)
			
	# Else, add the effect
	enemy.speed *= debuff.speed_multiplier
	enemy.sprite.modulate.b *= 1.5
	enemy.debuffs.append(new_debuff)
	
	# Add the timer
	new_debuff.timer = Utils.add_timer(enemy, debuff.duration, true, true)
	new_debuff.timer.connect("timeout", self, "remove_slow", [enemy, new_debuff])
	
	
func remove_slow(enemy, debuff):
	
	enemy.speed /= debuff.speed_multiplier
	enemy.sprite.modulate.b /= 1.5
	enemy.debuffs.erase(debuff)
	
			