# clue_layer.gd
extends Control
class_name ClueLayer

# size of each cell in the grid (must match PuzzleGrid.CELL_SIZE)
@export var cell_size : int = 24

func clear() -> void:
	# remove all existing clue labels
	for child in get_children():
		if child is Label:
			child.queue_free()

func set_clues(row_clues: Array, col_clues: Array) -> void:
	clear()

	# draw row clues to the left of the grid
	# each row_y at y * cell_size; labels stacked right-to-left
	for y in range(row_clues.size()):
		var rc: Array = row_clues[y]
		for i in range(rc.size()):
			var lbl := Label.new()
			lbl.text = str(rc[i])
			# position: -(number_of_clues - i) * cell_size, y * cell_size
			lbl.position = Vector2(-(rc.size() - i) * cell_size, y * cell_size)
			add_child(lbl)

	# draw column clues above the grid
	# each column_x at x * cell_size; labels stacked bottom-to-top
	for x in range(col_clues.size()):
		var cc: Array = col_clues[x]
		for i in range(cc.size()):
			var lbl := Label.new()
			lbl.text = str(cc[i])
			# position: x * cell_size, -(number_of_clues - i) * cell_size
			lbl.position = Vector2(x * cell_size, -(cc.size() - i) * cell_size)
			add_child(lbl)
# end clue_layer.gd
