extends Area2D
## Dormitory

## Preload doors
const DOOR_GREEN: CompressedTexture2D = preload("res://graphics/door_green.png")
const DOOR_RED: CompressedTexture2D = preload("res://graphics/door_red.png")

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


## Changes the sprite (color) of a door when a character arrives or dies
## [param id, character_death] id for door to change and information if the character dies (true) or arrives (false)
func door_change(id: int, character_death: bool) -> void:
	var sprite_door: Sprite2D = $Dormitory.get_child(id)
	if not (sprite_door == null):
		if character_death:
			sprite_door.texture = DOOR_RED
		else:
			sprite_door.texture = DOOR_GREEN
		print_debug("DOOR " + str(id) +  " CHANGED")
