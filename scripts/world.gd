extends Node2D
## World script

## Preload character
const CHARACTER = preload("res://scenes/character.tscn")

## Where a new character spawns
@onready var character_spawn: Vector2 = $CharacterSpawn.global_position

## Timer to automatically restart the game if no action (not moving a character) has been taken for 1 minute
@onready var timer_restart: Timer = $TimerRestart
const TIMER_RESTART_TIME: int = 60

## Production of the town
var production: int = 0

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	print(character_spawn)
	for i in 2:
		await get_tree().create_timer(1).timeout
		character_new_spawn()
	
	timer_restart.timeout.connect(automatic_restart)
	timer_restart.wait_time = TIMER_RESTART_TIME
	timer_restart.start()


## Any input
func _unhandled_input(event) -> void:
	# PC Escape
	if event.is_action_pressed("quit"):
		get_tree().quit()


## Spawns a new character
func character_new_spawn() -> void:
	var character = CHARACTER.instantiate()
	character.production.connect(_on_character_production)
	character.action_taken.connect(_on_character_action_taken)
	character.global_position = character_spawn
	add_child(character)


## When a characters works and produces value
## [param value] value that is added to the total
func _on_character_production(value: int) -> void:
	production += value
	print("PRODUCTION: " + str(production))
	$UI.update_label(production)


## Restart the timer to restart the game
func _on_character_action_taken() -> void:
	timer_restart.start()


## Automatically restarts the game
func automatic_restart() -> void:
	print("RESTARTING")
	get_tree().reload_current_scene()
