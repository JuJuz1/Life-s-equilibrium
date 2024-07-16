extends Area2D
## Recreation zone

@onready var audio_bird1 = $AudioStreamPlayer
@onready var audio_bird2 = $AudioStreamPlayer2


## When entering the zone
## [param area] area what enters, should always be a character
func _on_area_entered(area: Area2D) -> void:
	if not (audio_bird1.playing or audio_bird2.playing):
		if randf_range(0, 1) < 0.5:
			audio_bird1.play()
		else:
			audio_bird2.play()
	#print(area.facility)
	area.facility = "recreation_zone"
	area.energy_change = 6
	# Start timers and associated stuff in character script?
	#print(area.energy)
	#print(area.facility)


## When leaving
## [param area] area
func _on_area_exited(area: Area2D) -> void:
	#print(area.facility)
	area.energy_change = -1
	area.facility = "null"
	#print(area.facility)
