# puzzle_grid.gd
extends GridContainer
class_name PuzzleGrid

@export var cell_size : int = 24  # adjustable cell size in px

# ──── Inner cell class ────────────────────
class Cell extends Control:
	enum State { EMPTY, FILLED, MARKED }
	var state : int = State.EMPTY
	var error : bool = false

	func _ready() -> void:
		# use parent cell_size for dimensions
		var size_val : int = (get_parent() as PuzzleGrid).cell_size
		size = Vector2(size_val, size_val)
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if state == State.EMPTY:
				state = State.FILLED
			elif state == State.FILLED:
				state = State.MARKED
			else:
				state = State.EMPTY
			queue_redraw()

	func set_solution(v: bool) -> void:
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
		var bg : Color = Color.WHITE
		if state == State.FILLED:
			bg = Color.BLACK
		elif state == State.MARKED:
			bg = Color(0.5, 0.5, 0.5)
		draw_rect(Rect2(Vector2.ZERO, size), bg, true)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.2, 0.2, 0.2), false, 1)
		if error:
			draw_rect(Rect2(Vector2.ZERO, size), Color.RED, false, 2)

# ──── Grid logic ────────────────────────────
var solution   : Array[int] = []
var user_cells : Array[Cell] = []

func build_grid(grid_flat: Array[int], w: int, h: int) -> void:
	columns = w
	add_theme_constant_override("h_separation", 0)
	add_theme_constant_override("v_separation", 0)

	for cell in user_cells:
		cell.queue_free()
	user_cells.clear()
	solution = grid_flat.duplicate()

	for bit in grid_flat:
		var cell : Cell = Cell.new()
		add_child(cell)
		user_cells.append(cell)

func reset_cells() -> void:
	for cell in user_cells:
		cell.state = Cell.State.EMPTY
		cell.clear_error()

func reveal_solution() -> void:
	for i in range(solution.size()):
		user_cells[i].set_solution(solution[i])

func show_wrong_cells() -> void:
	for i in range(solution.size()):
		var should : int = solution[i]
		var is_filled : int = 1 if user_cells[i].state == Cell.State.FILLED else 0
		if should != is_filled:
			user_cells[i].show_error()
		else:
			user_cells[i].clear_error()

# end puzzle_grid.gd
