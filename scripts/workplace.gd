extends Area2D
## Workplace

## Variables
var has_adult: bool = false
var has_elderly: bool = false

## Array to hold workers
var workers: Array[Area2D]

## All animatedsprites
@onready var animations: Array = $Animations.get_children()
var tweening: bool = false

@onready var audio_stream_player = $AudioStreamPlayer

## When entering workplace
## [param area] area what enters, should always be a character
func _on_area_entered(area: Area2D) -> void:
	workers.append(area)
	animate(true)
	if area.age_group == Character.AgeGroup.ELDERLY:
		has_elderly = true
		area.production_value = 2
		area.energy_change = -3
	elif area.age_group == Character.AgeGroup.ADULT:
		has_adult = true
		if has_elderly:
			area.production_value = 3
		else:
			area.production_value = 2
		area.energy_change = -3
	elif area.age_group == Character.AgeGroup.CHILD:
		check_age_groups()
		if has_adult or has_elderly:
			area.production_value = 1
		else:
			area.production_value = 0
		area.energy_change = -2
	
	area.facility = "workplace"
	area.age_increase = 2
	
	# Start timers and associated stuff in character script?
	area.production_state_change(true)
	#print(area.energy)
	#print(area.facility)


## When leaving
## [param area] area
func _on_area_exited(area: Area2D) -> void:
	# Remove from array
	var index: int = workers.find(area)
	if not (index == -1):
		workers.remove_at(index)
	if workers.size() <= 0:
		animate(false)
	if area.age_group == Character.AgeGroup.ELDERLY:
		check_age_groups()
	if area.age_group == Character.AgeGroup.ADULT:
		check_age_groups()
	#print(area.facility)
	area.production_value = 0
	area.age_increase = 1
	area.energy_change = -1
	area.facility = "null"
	area.production_state_change(false)
	#print(area.facility)


## To animate and tween sprites
func animate(enabled: bool) -> void:
	if enabled:
		for animation: AnimatedSprite2D in animations:
			animation.play("default")
			var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(animation, "modulate:a", 1, 1)
	else:
		for animation: AnimatedSprite2D in animations:
			animation.stop()
			var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(animation, "modulate:a", 0, 1)


## Check elderly or adult status
func check_age_groups() -> void:
	for worker in workers:
		if worker.age_group == Character.AgeGroup.ELDERLY:
			has_elderly = true
		elif worker.age_group == Character.AgeGroup.ADULT:
			has_adult = true
