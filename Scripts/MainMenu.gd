extends Control


signal start


onready var start_button = find_node("StartButton")


func _ready():
	
	start_button.connect("pressed", self, "on_start_pressed")
	
	
func on_start_pressed() -> void:
	
	emit_signal("start")