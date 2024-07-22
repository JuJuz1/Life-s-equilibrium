extends PanelContainer
## Settings menu

@onready var audio_character_arrive: AudioStreamPlayer = $AudioCharacterArrive

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## When settings button is pressed
func _on_button_settings_pressed() -> void:
	# Pause the game, show settings menu
	#canvas_dim(true)
	get_tree().paused = true
	show()


func _on_button_close_pressed() -> void:
	hide()
	get_tree().paused = false
	#button_close.emit()


## Master volume, bus index 0
## Called every time the value changes, even when holding and sliding continously
func _on_h_slider_master_value_changed(value: float) -> void:
	set_bus_volume(0, value)
	if not audio_character_arrive.playing:
		audio_character_arrive.play()


## Music volume, bus index 1
func _on_h_slider_music_value_changed(value: float) -> void:
	set_bus_volume(1, value)


## Effects, bus index 2
func _on_h_slider_effects_value_changed(value: float) -> void:
	set_bus_volume(2, value)
	# Currently audio process always to finish the audio if menu is closed while playing
	if not audio_character_arrive.playing:
		audio_character_arrive.play()


## Sets bus volume based on the bus index and value
func set_bus_volume(bus_index: int, value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, value)
	
	# Set mute if lowest value, all the sliders have the same
	if value <= $MarginContainer/VBoxContainer/HSliderEffects.min_value:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)

