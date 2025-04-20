# nonogram_nonsense.gd
extends Control

# ─────────── Grid dimensions ───────────
const GRID_W : int = 10    # number of columns
const GRID_H : int = 15    # number of rows
const CELL_SIZE : int = 24 # pixel size per cell (used for preview scaling)

@onready var btn_generate : Button     = $Menu/GenerateBTN
@onready var btn_play     : Button     = $Menu/PlayBTN
@onready var btn_check    : Button     = $Menu/CheckBTN
@onready var btn_solve    : Button     = $Menu/CheckBTN # Note: CheckBTN for check, SolveBTN has custom logic

@onready var preview      : TextureRect = $Puzzle/PreviewRect
@onready var grid         : PuzzleGrid  = $Puzzle/Grid
@onready var clues        : ClueLayer   = $Puzzle/Clues

var current_grid : Array[int] = []    # flat length GRID_W*GRID_H
var row_clues    : Array      = []    # lists of clue strings
var col_clues    : Array      = []

func _ready() -> void:
	preview.show()
	grid.hide()

	btn_generate.pressed.connect(_on_generate)
	btn_play.pressed.   connect(_on_play)
	btn_check.pressed.  connect(_on_check)
	btn_solve.pressed.  connect(_on_solve)

func _on_generate() -> void:
	_build_random_puzzle()

	# Build a 1px-per-cell image
	var img := Image.create(GRID_W, GRID_H, false, Image.FORMAT_L8)
	for y in range(GRID_H):
		for x in range(GRID_W):
			img.set_pixel(x, y,
				Color.BLACK if current_grid[y * GRID_W + x] else Color.WHITE
			)
	# Resize on CPU to CELL_SIZE multiples, nearest neighbor
	img.resize(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE, Image.INTERPOLATE_NEAREST)

	var tex := ImageTexture.create_from_image(img)

	# Assign texture and set preview to exact size (no additional scaling)
	preview.texture                = tex
	preview.custom_minimum_size    = Vector2(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE)
	preview.expand_mode            = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode           = TextureRect.STRETCH_KEEP
	preview.show()

	clues.set_clues(row_clues, col_clues)
	grid.hide()

func _on_play() -> void:
	preview.hide()
	grid.show()
	grid.build_grid(current_grid, GRID_W, GRID_H)
	clues.set_clues(row_clues, col_clues)
	grid.reset_cells()

func _on_check() -> void:
	grid.show_wrong_cells()

func _on_solve() -> void:
	grid.reveal_solution()

func _build_random_puzzle() -> void:
	# Prepare flat array
	current_grid.resize(GRID_W * GRID_H)
	for i in range(current_grid.size()):
		current_grid[i] = int(randf() < 0.5)

	# Build matrix for clues
	var mat := []
	for y in range(GRID_H):
		var start := y * GRID_W
		mat.append(current_grid.slice(start, start + GRID_W))

	row_clues = _compute_clues(mat)
	col_clues = _compute_clues(_transpose(mat))

func _compute_clues(mat : Array) -> Array:
	var out := []
	for line in mat:
		var res := []
		var cnt := 0
		for v in line:
			if v == 1:
				cnt += 1
			elif cnt > 0:
				res.append(str(cnt))
				cnt = 0
		if cnt > 0:
			res.append(str(cnt))
		if res.is_empty():
			res.append("0")
		out.append(res)
	return out

func _transpose(mat : Array) -> Array:
	var out := []
	if mat.is_empty():
		return out
	var w := (mat[0] as Array).size()
	var h := mat.size()
	for x in range(w):
		var col := []
		for y in range(h):
			col.append(mat[y][x])
		out.append(col)
	return out

# end nonogram_nonsense.gd
