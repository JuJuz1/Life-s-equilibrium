extends Control
## Character labels

var tween_running: bool = false

## Update labels
## [param age, energy] character's age and energy level
func labels_update(age: int, energy: int) -> void:
	$LabelAge.text = str(age)
	$LabelEnergy.text = str(energy) + "/100"


## Show a message giving information about a character's state
## [param message] what message to show (energy or sickness for now)
func state_label_show(message: String) -> void:
	if tween_running:
		return
	tween_running = true
	$LabelState.text = message
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($LabelState, "modulate:a", 1, 0.5)
	await get_tree().create_timer(2).timeout
	# Have to reassign, otherwise throws tween not valid error
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($LabelState, "modulate:a", 0, 1)
	tween.finished.connect(func() -> void:
		tween_running = false)
