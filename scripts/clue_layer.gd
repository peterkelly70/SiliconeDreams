# ─────────────────────────────────────────────
#  clue_layer.gd   (attach to Control “Clues”)
# ─────────────────────────────────────────────
extends Control
class_name ClueLayer

# These must exist as direct children of this node:
@onready var row_vbox : VBoxContainer = $RowVBox
@onready var col_hbox : HBoxContainer = $ColHBox

func clear() -> void:
	# safe: row_vbox and col_hbox are always valid
	for c in row_vbox.get_children():
		c.queue_free()
	for c in col_hbox.get_children():
		c.queue_free()

func set_clues(row_clues:Array, col_clues:Array) -> void:
	clear()
	# populate row numbers
	for rc in row_clues:
		var lbl := Label.new()
		lbl.text = " ".join(rc)
		row_vbox.add_child(lbl)

	# populate column numbers
	for cc in col_clues:
		var lbl := Label.new()
		lbl.text = " ".join(cc)
		col_hbox.add_child(lbl)
# ─────────────────────────────────────────────
#  end clue_layer.gd
# ─────────────────────────────────────────────
