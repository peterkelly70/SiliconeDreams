extends Control
class_name ClueLayer

@export var cell_size : int = 24     # squares are 24 px in PuzzleController

# children created at runtime
var row_vbox : VBoxContainer
var col_hbox : HBoxContainer

func _ready() -> void:
	# two temporary containers for labels
	row_vbox = VBoxContainer.new()
	add_child(row_vbox)

	col_hbox = HBoxContainer.new()
	add_child(col_hbox)

func clear() -> void:
	for c in row_vbox.get_children():
		c.queue_free()
	for c in col_hbox.get_children():
		c.queue_free()

func show_clues(row_clues : Array, col_clues : Array) -> void:
	clear()

	# row numbers (left of grid)
	for rc in row_clues:
		var lbl := Label.new()
		lbl.text = " ".join(rc)
		row_vbox.add_child(lbl)

	# column numbers (above grid)
	for cc in col_clues:
		var lbl := Label.new()
		lbl.text = " ".join(cc)
		col_hbox.add_child(lbl)

	# position containers: left & top of grid
	row_vbox.position = Vector2(-row_vbox.size.x, 0)
	col_hbox.position = Vector2(0, -col_hbox.size.y)
