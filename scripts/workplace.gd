extends Area2D
## Workplace mechanics

## When entering workplace
func _on_area_entered(area: Area2D) -> void:
	print(area.facility)
	area.facility = "workplace"
	area.age_increase = 2
	# Start timers and associated stuff in character script?
	area.energy -= 10
	print(area.energy)
	print(area.facility)


## When leaving
func _on_area_exited(area: Area2D) -> void:
	print(area.facility)
	area.facility = "null"
	print(area.facility)
