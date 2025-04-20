extends Object
class_name RandomPuzzleGenerator

# Public API: returns a flat Array of bools, length = width*height
func generate(width: int, height: int) -> Array:
	var grid2d = _generate_binary_grid(width, height)
	var flat: Array = []
	for row in grid2d:
		for cell in row:
			flat.append(cell == 1)
	return flat

# Optional: build clues and save 2D grid + clues as JSON
func generate_and_save_random_puzzle(width: int, height: int) -> String:
	var grid2d = _generate_binary_grid(width, height)
	var clues = compute_clue_sets(grid2d)
	var puzzle_data = {
		"width": width,
		"height": height,
		"grid": grid2d,
		"row_clues": clues["row_clues"],
		"col_clues": clues["col_clues"]
	}
	var ts = Time.get_unix_time_from_system()
	var filename = "user://puzzles/random_puzzle_%d.json" % ts

	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("puzzles"):
		dir.make_dir_recursive("puzzles")

	var f = FileAccess.open(filename, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(puzzle_data, "\t"))
		f.close()
		return filename
	return ""

#--- private helpers -------------------------------------------------------

func _generate_binary_grid(width: int, height: int) -> Array:
	var grid: Array = []
	for y in range(height):
		var row: Array = []
		for x in range(width):
			# Python‑style ternary: 1 if <50% else 0
			row.append(1 if randf() < 0.5 else 0)
		grid.append(row)
	return grid

func _compute_clues(line: Array) -> Array:
	var clues: Array = []
	var count := 0
	for v in line:
		if v == 1:
			count += 1
		elif count > 0:
			clues.append(count)
			count = 0
	if count > 0:
		clues.append(count)
	if clues.is_empty():
		clues.append(0)
	return clues

func compute_clue_sets(grid: Array) -> Dictionary:
	var h = grid.size()
	var w = (grid[0] as Array).size()
	var row_clues: Array = []
	var col_clues: Array = []

	for row in grid:
		row_clues.append(_compute_clues(row))

	for x in range(w):
		var col: Array = []
		for y in range(h):
			col.append(grid[y][x])
		col_clues.append(_compute_clues(col))
	return {
		"row_clues": row_clues,
		"col_clues": col_clues
	}
