extends Area2D
## Dormitory

## When entering the dormitory
## [param area] area what enters, should always be a character
func _on_area_entered(area: Area2D) -> void:
	#print(area.facility)
	area.facility = "dormitory"
	area.energy_change = 0
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
