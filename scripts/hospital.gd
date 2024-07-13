extends Area2D
## Hospital

## When entering the hospital
## [param area] area what enters, should always be a character
func _on_area_entered(area: Area2D) -> void:
	area.facility = "hospital"
	area.energy_change = 0
	# Start timers and associated stuff in character script?


## When leaving
## [param area] area
func _on_area_exited(area: Area2D) -> void:
	area.energy_change = -1
	area.facility = "null"
