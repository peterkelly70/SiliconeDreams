extends Node

# Entry point for standalone test
func _ready() -> void:
	randomize()
	generate_and_save_random_puzzle(15, 15)

# Step 1: Create a random binary grid
func generate_binary_grid(width: int, height: int) -> Array:
	var grid := []  # Array of Array[int]
	for y in range(height):
		var row := []  # Array[int]
		for x in range(width):
			row.append(1 if randf() < 0.5 else 0)
		grid.append(row)
	return grid

# Step 2: Compute clues from a line of 1s and 0s
func compute_clues(line: Array) -> Array:
	var clues := []  # Array[int]
	var count := 0
	for cell in line:
		if cell == 1:
			count += 1
		elif count > 0:
			clues.append(count)
			count = 0
	if count > 0:
		clues.append(count)
	if clues.is_empty():
		clues.append(0)
	return clues

# Step 3: Compute all row and column clues from the grid
func compute_clue_sets(grid: Array) -> Dictionary:
	var width: int = (grid[0] as Array).size()
	var height: int = grid.size()

	var row_clues := []  # Array of Array[int]
	var col_clues := []  # Array of Array[int]

	for row in grid:
		row_clues.append(compute_clues(row))

	for x in range(width):
		var col := []
		for y in range(height):
			col.append(grid[y][x])
		col_clues.append(compute_clues(col))

	return {
		"row_clues": row_clues,
		"col_clues": col_clues
	}

# Step 4: Save puzzle to JSON and return the filename
func generate_and_save_random_puzzle(width: int, height: int) -> String:
	var grid := generate_binary_grid(width, height)
	var clues := compute_clue_sets(grid)

	var puzzle_data := {
		"width": width,
		"height": height,
		"grid": grid,
		"row_clues": clues["row_clues"],
		"col_clues": clues["col_clues"]
	}

	var timestamp: int = Time.get_unix_time_from_system()
	var filename: String = "user://puzzles/random_puzzle_%d.json" % timestamp

	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("puzzles"):
		var err := dir.make_dir_recursive("puzzles")
		print("Created puzzles directory. Result:", err)

	var file := FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(puzzle_data, "\t"))  # Pretty print
		file.close()
		print("✅ Saved puzzle to:", filename)
		return filename
	else:
		printerr("❌ Could not write puzzle to:", filename)
		return ""
