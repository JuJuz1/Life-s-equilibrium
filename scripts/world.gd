extends Node2D
## World script

const CHARACTER = preload("res://scenes/character.tscn")

## Production of the town
var production: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	for i in 2:
		await get_tree().create_timer(0.5).timeout
		var character = CHARACTER.instantiate()
		character.production.connect(_on_character_production)
		add_child(character)


func _input(event) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()


## When a characters works and produces value
## [param value] value that is added to the total
func _on_character_production(value: int) -> void:
	production += value
	print("PRODUCTION: " + str(production))
	$Control.update_label(production)
