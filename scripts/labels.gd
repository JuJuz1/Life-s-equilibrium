extends Control
## Character labels

var tween_running: bool = false

## Update labels
## [param age, energy] character's age and energy level
func labels_update(age: int, energy: int) -> void:
	$LabelAge.text = str(age)
	$LabelEnergy.text = str(energy) + "/100" # TODO
	$EnergyBar.value = energy


## Show a message giving information about a character's state
## [param message] what message to show (energy or sickness for now)
func state_label_show(message: String) -> void:
	if tween_running:
		return
	tween_running = true
	$LabelState.text = message
	
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	var tween_font_color: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops(1).set_parallel(true)
	
	tween.tween_property($LabelState, "modulate:a", 1, 0.5)
	
	# Tween font colors
	tween_font_color.tween_property($LabelState, "modulate:r", 0.75, 1)
	tween_font_color.tween_property($LabelState, "modulate:g", 0.75, 1)
	tween_font_color.tween_property($LabelState, "modulate:b", 0.75, 1)
	
	tween_font_color.chain().tween_property($LabelState, "modulate:r", 1, 1)
	tween_font_color.tween_property($LabelState, "modulate:g", 1, 1)
	tween_font_color.tween_property($LabelState, "modulate:b", 1, 1)
	
	await get_tree().create_timer(3).timeout
	# Have to reassign, otherwise throws tween not valid error
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($LabelState, "modulate:a", 0, 1)
	tween.finished.connect(func() -> void:
		tween_running = false)
