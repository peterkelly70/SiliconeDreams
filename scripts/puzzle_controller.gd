# res://scripts/PuzzleController.gd
extends Control
class_name PuzzleController

@export var cell_size: int       = 24
@export var grid_offset: Vector2 = Vector2(50, 50)

var cells: Array          = []
var user_selection: Array = []
var puzzle_data: Array    = []
var grid_w: int           = 0
var grid_h: int           = 0

# ClueLayer is at ../Puzzle/ClueLayer
@onready var clue_layer: Control = get_node("../Puzzle/ClueLayer")

func render(puzzle_flat: Array, w: int, h: int) -> void:
	puzzle_data = puzzle_flat
	grid_w = w
	grid_h = h
	_clear()
	_draw_clues()
	_spawn_cells()

func show_solution() -> void:
	for i in range(cells.size()):
		cells[i].set_filled(puzzle_data[i])

func clear_errors() -> void:
	for c in cells:
		c.clear_error()

func show_error(idx: int) -> void:
	cells[idx].show_error()

#–– private helpers ––#

func _spawn_cells() -> void:
	var CellScene = preload("res://scenes/PuzzleCell.tscn")
	for y in range(grid_h):
		for x in range(grid_w):
			var idx = y * grid_w + x
			var cell = CellScene.instantiate()
			cell.position = grid_offset + Vector2(x, y) * cell_size
			cell.filled = puzzle_data[idx]
			add_child(cell)
			cells.append(cell)
			user_selection.append(false)

func _clear() -> void:
	for c in cells:
		c.queue_free()
	cells.clear()
	user_selection.clear()
	_clear_clues()

func _draw_clues() -> void:
	_clear_clues()

	# Row clues
	for y in range(grid_h):
		var runs: Array = []
		var count: int = 0
		for x in range(grid_w):
			if puzzle_data[y * grid_w + x]:
				count += 1
			elif count > 0:
				runs.append(count)
				count = 0
		if count > 0:
			runs.append(count)

		# build space‑separated string
		var txt := ""
		if runs.size() == 0:
			txt = "0"
		else:
			for i in range(runs.size()):
				txt += str(runs[i])
				if i < runs.size() - 1:
					txt += " "

		var lbl = Label.new()
		lbl.text = txt
		lbl.position = Vector2(
			grid_offset.x - lbl.get_minimum_size().x - 4,
			grid_offset.y + y * cell_size
		)
		clue_layer.add_child(lbl)

	# Column clues
	for x in range(grid_w):
		var runs: Array = []
		var count: int = 0
		for y in range(grid_h):
			if puzzle_data[y * grid_w + x]:
				count += 1
			elif count > 0:
				runs.append(count)
				count = 0
		if count > 0:
			runs.append(count)

		# build newline‑separated string
		var txt2 := ""
		if runs.size() == 0:
			txt2 = "0"
		else:
			for i in range(runs.size()):
				txt2 += str(runs[i])
				if i < runs.size() - 1:
					txt2 += "\n"

		var lbl2 = Label.new()
		lbl2.text = txt2
		lbl2.position = Vector2(
			grid_offset.x + x * cell_size,
			grid_offset.y - lbl2.get_minimum_size().y - 4
		)
		clue_layer.add_child(lbl2)

func _clear_clues() -> void:
	for child in clue_layer.get_children():
		child.queue_free()
