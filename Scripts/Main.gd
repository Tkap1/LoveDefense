extends Control


var main_menu
var game


func _ready():
	
	init_main_menu()

	
func init_main_menu() -> void:
	
	main_menu = load("res://Scenes/MainMenu.tscn").instance()
	add_child(main_menu)
	main_menu.connect("start", self, "start_game")
	
	
func start_game() -> void:
	
	main_menu.queue_free()
	
	game = load("res://Scenes/Game.tscn").instance()
	add_child(game)
	game.connect("game_over", self, "on_game_over")
	
	
func on_game_over():
	
	game.queue_free()
	init_main_menu()
	