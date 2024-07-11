extends Area2D
## Workplace mechanics

## When entering workplace
## [param area] area what enters, should always be a character
func _on_area_entered(area: Area2D) -> void:
	print(area.facility)
	area.facility = "workplace"
	area.age_increase = 2
	# Start timers and associated stuff in character script?
	area.production_state_change(true)
	area.energy -= 10
	print(area.energy)
	print(area.facility)


## When leaving
## [param area] area
func _on_area_exited(area: Area2D) -> void:
	print(area.facility)
	area.age_increase = 1
	area.facility = "null"
	area.production_state_change(false)
	print(area.facility)
