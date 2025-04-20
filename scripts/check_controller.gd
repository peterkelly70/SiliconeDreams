# CheckController.gd
extends Node

func check(user_selections: Array, solution: Array, width: int, height: int) -> Array:
	var errors = []
	
	# Ensure we have valid data
	if user_selections.size() != solution.size():
		print("ERROR: User selections and solution arrays have different sizes")
		return errors
	
	# Check each cell
	for i in range(user_selections.size()):
		# If user selected a cell that should be empty, or
		# didn't select a cell that should be filled
		if (user_selections[i] and not solution[i]) or (not user_selections[i] and solution[i]):
			errors.append(i)
	
	print("Found " + str(errors.size()) + " errors in solution")
	return errors
