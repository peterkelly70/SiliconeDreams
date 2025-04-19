# main.gd
extends Node

@onready var scene_loader: Node = $SceneLoader

func _ready() -> void:
	StateManager.connect("state_changed", Callable(self, "_on_state_changed"))
	_on_state_changed(StateManager.current_state)

func _on_state_changed(new_state: int) -> void:
	# Clear old scene
	for child in scene_loader.get_children():
		child.queue_free()

	var scene_path: String = _get_scene_path(new_state)
	if scene_path == "":
		push_error("Unknown game state: %s" % str(new_state))
		return

	var packed_scene: PackedScene = load(scene_path)
	if packed_scene:
		var instance: Node = packed_scene.instantiate()
		scene_loader.add_child(instance)
	else:
		push_error("Failed to load scene: %s" % scene_path)

func _get_scene_path(state: int) -> String:
	match state:
		StateManager.GameState.SPLASH:
			return "res://scenes/splash_screen.tscn"
		StateManager.GameState.PUZZLE:
			return "res://scenes/puzzle_screen.tscn"
		_:
			return ""
# main.gd
