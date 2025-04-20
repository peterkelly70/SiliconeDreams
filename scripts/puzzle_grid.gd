# puzzle_grid.gd
extends GridContainer
class_name PuzzleGrid

@export var cell_size : int = 24  # pixels per cell

# ──── Inner Cell ───────────────────────────────
class Cell extends Control:
	enum State { EMPTY, FILLED, MARKED }
	var state : int = State.EMPTY
	var error : bool = false

	func _ready() -> void:
		# retrieve cell_size from parent PuzzleGrid
		var parent_grid := get_parent() as PuzzleGrid
		var size_val : int = parent_grid.cell_size
		size = Vector2(size_val, size_val)
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# cycle through states without ternary
			if state == State.EMPTY:
				state = State.FILLED
			elif state == State.FILLED:
				state = State.MARKED
			else:
				state = State.EMPTY
			queue_redraw()

	func set_solution(v: bool) -> void:
		# explicit if/else instead of ternary
		if v:
			state = State.FILLED
		else:
			state = State.EMPTY
		queue_redraw()

	func clear_error() -> void:
		error = false
		queue_redraw()

	func show_error() -> void:
		error = true
		queue_redraw()

	func _draw() -> void:
		# fill background
		var bg: Color = Color.WHITE
		if state == State.FILLED:
			bg = Color.BLACK
		elif state == State.MARKED:
			bg = Color(0.5, 0.5, 0.5)
		draw_rect(Rect2(Vector2.ZERO, size), bg, true)

		# grey border around each cell
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.3, 0.3), false, 1)

		# red outline for errors
		if error:
			draw_rect(Rect2(Vector2.ZERO, size), Color.RED, false, 2)

# ──── Grid State ───────────────────────────────
var solution_flat : Array[int] = []   # flattened solution
var user_cells    : Array[Cell] = []  # list of instantiated cells

# ──── Build from 2D array ───────────────────────
func build_grid_2d(grid2d: Array, w: int, h: int) -> void:
	# clear existing cells
	for c in user_cells:
		c.queue_free()
	user_cells.clear()
	solution_flat.clear()

	columns = w

	# instantiate row by row
	for y in range(h):
		for x in range(w):
			var v = grid2d[y][x]
			# collect solution
			solution_flat.append(int(v))
			# create cell
			var c = Cell.new()
			add_child(c)
			# initial fill state
			if v == 1:
				c.state = Cell.State.FILLED
			else:
				c.state = Cell.State.EMPTY
			user_cells.append(c)

func reset_cells() -> void:
	for c in user_cells:
		c.state = Cell.State.EMPTY
		c.clear_error()

func reveal_solution() -> void:
	for i in range(solution_flat.size()):
		var val : int = solution_flat[i]
		if val == 1:
			user_cells[i].set_solution(true)
		else:
			user_cells[i].set_solution(false)

func show_wrong_cells() -> void:
	for i in range(solution_flat.size()):
		var should : int = solution_flat[i]
		var is_filled : int
		if user_cells[i].state == Cell.State.FILLED:
			is_filled = 1
		else:
			is_filled = 0
		if should != is_filled:
			user_cells[i].show_error()
		else:
			user_cells[i].clear_error()
