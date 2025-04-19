extends Node

# Returns a partially or fully solved grid based on clues
# Returns: Array of rows (each row is Array[int]) or null if failed
func solve_puzzle(row_clues: Array, col_clues: Array) -> Array:
	var height: int = row_clues.size()
	var width: int = col_clues.size()

	# Create grid filled with -1 (unknown)
	var grid: Array = []
	for _i in range(height):
		var row: Array = []
		for _j in range(width):
			row.append(-1)
		grid.append(row)

	# Naive row-based solver (fills rows if clues exactly match width)
	for y in range(height):
		var filled: int = 0
		for clue in row_clues[y]:
			filled += int(clue)

		var gaps: int = row_clues[y].size() - 1
		var total: int = filled + gaps

		if total == width:
			var line: Array = []
			for clue_i in range(row_clues[y].size()):
				var clue: int = int(row_clues[y][clue_i])
				for _k in range(clue):  # Correct loop
					line.append(1)
				if line.size() < width:
					line.append(0)
			grid[y] = line

	return grid
