extends Control
## Character labels

## Update labels
## [param age, energy] character's age and energy level
func labels_update(age: int, energy: int) -> void:
	$LabelAge.text = str(age)
	$LabelEnergy.text = str(energy) + "/100"
