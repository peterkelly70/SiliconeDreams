extends Control

# --------------------------------------------------
# Configuration
# --------------------------------------------------
@export var cell_scene   : PackedScene = preload("res://scenes/puzzle_cell.tscn")
@export var cell_size_px : int = 24          # pixel size of one square

# --------------------------------------------------
# Public state (used by Play / Check controllers)
# --------------------------------------------------
var cells          : Array[Control] = []
var user_selection : Array[bool]    = []

# --------------------------------------------------
# Build or rebuild the grid
# --------------------------------------------------
func render(puzzle_flat : Array, w : int, h : int) -> void:
	# clear previous cells
	for c in cells:
		c.queue_free()
	cells.clear()
	user_selection.clear()

	# set this node’s size, so layout behaves
	custom_minimum_size = Vector2(w, h) * cell_size_px

	# create new cells
	var index := 0
	for y in range(h):
		for x in range(w):
			var cell : Control = cell_scene.instantiate()
			cell.position = Vector2(x * cell_size_px, y * cell_size_px)
			cell.size     = Vector2(cell_size_px, cell_size_px)

			cell.set_filled(puzzle_flat[index])
			cell.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
			cell.gui_input.connect(_on_cell_input.bind(index))

			add_child(cell)
			cells.append(cell)
			user_selection.append(false)
			index += 1

# --------------------------------------------------
# Error helpers
# --------------------------------------------------
func clear_errors() -> void:
	for c in cells:
		c.clear_error()

func show_error(idx : int) -> void:
	if idx >= 0 and idx < cells.size():
		cells[idx].show_error()

# --------------------------------------------------
# Mouse click on a cell
# --------------------------------------------------
func _on_cell_input(event : InputEvent, idx : int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var cell : Control = cells[idx]
		cell.selected       = not cell.selected
		user_selection[idx] = cell.selected
		cell.queue_redraw()
