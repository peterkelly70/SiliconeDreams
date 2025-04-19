# state_manager.gd
extends Node

enum GameState {
	SPLASH,
	PUZZLE,
	OPTIONS,
	EXIT,
	SAVE,
	LOAD
}

signal state_changed(new_state)

var current_state: int = GameState.SPLASH

func set_state(new_state: int):
	if current_state != new_state:
		current_state = new_state
		emit_signal("state_changed", new_state)
# state_manager.gd
