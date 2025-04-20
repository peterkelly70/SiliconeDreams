extends Control
class_name PuzzleController

@export var cell_scene   : PackedScene = preload("res://scenes/puzzle_cell.tscn")
@export var cell_size_px : int = 24

var cells          : Array[Control] = []
var user_selection : Array[bool]    = []

func render(puzzle_flat : Array, w : int, h : int) -> void:
	for c in cells: c.queue_free()
	cells.clear()
	user_selection.clear()

	custom_minimum_size = Vector2(w, h) * cell_size_px

	var idx := 0
	for y in range(h):
		for x in range(w):
			var cell : Control = cell_scene.instantiate()
			cell.position = Vector2(x, y) * cell_size_px
			cell.size     = Vector2(cell_size_px, cell_size_px)
			cell.set_filled(puzzle_flat[idx])
			cell.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
			cell.gui_input.connect(_on_cell_click.bind(idx))

			add_child(cell)
			cells.append(cell)
			user_selection.append(false)
			idx += 1

func _on_cell_click(event : InputEvent, idx : int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var cell := cells[idx]
		# cycle: white → black → grey → white
		if not cell.filled and not cell.selected:
			cell.filled = true
		elif cell.filled:
			cell.filled = false
			cell.selected = true   # grey state
		else:
			cell.selected = false  # back to white
		user_selection[idx] = cell.filled
		cell.queue_redraw()

func clear_errors() -> void:
	for c in cells: c.clear_error()

func show_error(i:int)->void:
	if i>=0 and i<cells.size(): cells[i].show_error()
