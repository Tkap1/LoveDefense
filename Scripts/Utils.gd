extends Node



func add_sprite(parent, texture, size : Vector2) -> Sprite:
	
	var sprite = Sprite.new()
	parent.add_child(sprite)
	sprite.texture = texture
	sprite.scale = size / texture.get_size()
	return sprite
	
	
func add_timer(parent, duration : float, autostart := true, one_shot := true) -> Timer:
	
	var timer = Timer.new()
	timer.wait_time = duration
	timer.autostart = autostart
	timer.one_shot = one_shot
	parent.add_child(timer)
	return timer
	
	
	
func pos2tile_pos(position):
	
	return (position / Cfg.tile_size).floor() * Cfg.tile_size
	
	
func tile_center(position):
	
	return position + Cfg.tile_size / 2
	
	