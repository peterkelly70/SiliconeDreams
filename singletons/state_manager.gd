extends Node

enum GameState { SPLASH, PUZZLE }

signal state_changed(new_state)

var current_state: GameState = GameState.SPLASH setget set_state

func set_state(new_state):
    if current_state != new_state:
        current_state = new_state
        emit_signal("state_changed", new_state)
