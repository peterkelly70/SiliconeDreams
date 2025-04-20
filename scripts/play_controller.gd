extends Node
class_name PlayerController     # rename if you prefer PlayController

# ------------------------------------------------------------------
# State
# ------------------------------------------------------------------
var puzzle_controller : Node = null        # reference to the active PuzzleController
var is_play_mode      : bool = false

# ------------------------------------------------------------------
# Called from NonogramNonsense when the user hits “Play”
# ------------------------------------------------------------------
func start_play(controller : Node) -> void:
	puzzle_controller = controller
	is_play_mode      = true

	if puzzle_controller == null:
		push_error("PlayerController: start_play called with null controller")
		return

	if not puzzle_controller.has_method("cells"):
		push_error("PlayerController: controller has no 'cells' array")
		return

	var cell_array : Array = puzzle_controller.cells
	for cell in cell_array:
		# Enable mouse interactions (left click handled inside PuzzleController)
		cell.set_mouse_filter(Control.MOUSE_FILTER_STOP)

# ------------------------------------------------------------------
# Called by NonogramNonsense when user generates / loads a new puzzle
# or when “Reset” is required
# ------------------------------------------------------------------
func reset_selections() -> void:
	is_play_mode = false

	if puzzle_controller == null:
		return

	var cell_array : Array = puzzle_controller.cells
	var selection  : Array = puzzle_controller.user_selection

	var count : int = cell_array.size()
	for i in range(count):
		var cell = cell_array[i]
		cell.selected = false
		cell.clear_error()
		selection[i]  = false

		# Disable mouse interaction when not in play mode
		cell.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
