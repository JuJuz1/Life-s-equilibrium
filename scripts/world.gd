extends Node2D
## World script

## Preload character
const CHARACTER = preload("res://scenes/character.tscn")

## Where a new character spawns
@onready var character_spawn: Vector2 = $CharacterSpawn.global_position

## Timer to automatically restart the game if no action (not moving a character) has been taken for 1 minute
@onready var timer_restart: Timer = $TimerRestart
const TIMER_RESTART_TIME: int = 60

## Production of the town and limit when a new character arrives
var production: int = 0
var production_limit: int = 5

## Array to hold character references throughout the game, useful for all operations considering characters
## Determines which doors are colored green and which are red
var characters: Array = Array()

## Used when starting game
var started: bool = false

func _ready() -> void:
	# Initialize the array
	characters.resize(15)
	characters.fill(0)


## Any input
func _unhandled_input(event) -> void:
	# PC Escape
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("click"):
		if started:
			return
		start()


## Starts game and tutorial 
func start() -> void:
	if started:
		return
	started = true
	# TODO: change amount
	for i in 1:
		await get_tree().create_timer(2).timeout
		character_new_spawn()
	
	timer_restart.timeout.connect(automatic_restart)
	timer_restart.wait_time = TIMER_RESTART_TIME
	timer_restart.start()


## Spawns a new character
func character_new_spawn() -> void:
	var character = CHARACTER.instantiate()
	character.production.connect(_on_character_production)
	character.action_taken.connect(_on_character_action_taken)
	character.death.connect(_on_character_death)
	
	# TODO: change position
	#character.global_position = character_spawn
	character.global_position = Vector2(100,100)
	
	# Find the first slot that doesn't contain a character reference
	# Assign to the array and assing an id based on the position in the array
	for i in characters.size() - 1:
		if characters[i] is not Character:
			characters[i] = character
			character.id = i
			break
	
	add_child(character)
	
	var amount: int = characters_amount()
	if amount >= 15:
		print("WON")
		pass
		# Game win


## Check how many characters are currently alive
## [returns count] the amount of characters alive
func characters_amount() -> int:
	var count: int = 0
	for i in characters.size() - 1:
		if characters[i] is Character:
			count += 1
	return count


## Restart the timer to restart the game
func _on_character_action_taken() -> void:
	timer_restart.start()


## When a character dies
## [param id] character's id
func _on_character_death(id: int) -> void:
	characters[id] = 0
	# TODO: needs to be tested
	production_limit = int(production_limit * 0.75)
	# Make correct door red
	var amount: int = characters_amount()
	if amount <= 0:
		automatic_restart()
		# Game lose


## When a characters works and produces value
## Increases production limit in correlation to current production
## [param value] value that is added to the total
func _on_character_production(value: int) -> void:
	production += value
	print("PRODUCTION LIMIT: " + str(production_limit))
	if production >= production_limit:
		production_limit += production #lerp(production, production + production_limit, 1)
		character_new_spawn()
		print("NEW PRODUCTION LIMIT: " + str(production_limit))
	#print("PRODUCTION: " + str(production))
	$UI.update_label(production)


## Automatically restarts the game
func automatic_restart() -> void:
	print("RESTARTING")
	get_tree().reload_current_scene()
