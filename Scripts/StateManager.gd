extends Node
class_name StateManager

var parent
var states : Dictionary
var current_state : Dictionary
var current_state_key : String

var state_stack = []

func _init(_parent, _states):
	parent = _parent
	states = _states
	
	
func process(delta) -> void:
	
	for update in current_state.updates:
		if parent.call(update, current_state.data, delta) == "break":
			break
			
	if "draw" in current_state and current_state.draw:
		parent.update()
		
		
func set_state(new_state : String, data := {}) -> void:
	
	if current_state != null:
		if "on_leave" in current_state:
			parent.call(current_state.on_leave, current_state.data)
		state_stack.append(current_state_key)
			
	if new_state == "previous":
		var previous_state = state_stack.pop_back()
		current_state = states[previous_state]
		current_state_key = previous_state
	else:
		current_state = states[new_state]
		current_state_key = new_state
		
		
	for key in data:
		current_state.data[key] = data[key]
	
	if "on_enter" in current_state:
		parent.call(current_state.on_enter, current_state.data)
	
	