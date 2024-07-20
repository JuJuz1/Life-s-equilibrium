extends Node2D
## World script

## Signals
signal tutorial_over ## To know when tutorial is over

## Preload characters
const CHARACTER_BASE = preload("res://scenes/character_base.tscn")
const CHARACTER_BOY = preload("res://scenes/character_boy.tscn")
const CHARACTER_GIRL_2 = preload("res://scenes/character_girl2.tscn")
const CHARACTER_GIRL = preload("res://scenes/character_girl.tscn")

## Unshaded material
const MATERIAL_UNSHADED = preload("res://materials/material_unshaded.tres")

## All preloaded characters
var characters_preload: Array[PackedScene]

## Where a new character spawns
@onready var character_spawn: Vector2 = $CharacterSpawn.global_position

## Save canvasmodulate tint
var canvas_tint: Color

## Timer to automatically restart the game if no action (not moving a character) has been taken for 1 minute
@onready var timer_restart: Timer = $TimerRestart
const TIMER_RESTART_TIME: int = 60

## Day-night cycle
@onready var timer_cycle = $TimerCycle
const TIMER_CYCLE_TIME: int = 30 #TODO

## Production of the town and limit when a new character arrives
var production: int = 0
var production_limit: int = 5

## Array to hold character references throughout the game, useful for all operations considering characters
## Determines which doors are colored green and which are red, as well as a lot more
var characters: Array = Array()

## Used when starting game
var started: bool = false
## When a small tutorial is ongoing
var tutorial: bool = true

## Music starts playing after tutorial
@onready var audio_music = $AudioMusic
@onready var audio_character_arrive = $AudioCharacterArrive
@onready var audio_character_death = $AudioCharacterDeath

func _ready() -> void:
	characters_preload.append(CHARACTER_BASE)
	characters_preload.append(CHARACTER_BOY)
	characters_preload.append(CHARACTER_GIRL)
	characters_preload.append(CHARACTER_GIRL_2)
	
	# Initialize the array
	characters.resize(15)
	characters.fill(0)
	
	canvas_tint = $CanvasModulate.color


## Any input
func _unhandled_input(event) -> void:
	# PC Escape
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("click"):
		#if started:
			#night()
			#return
		start()


## Starts game and tutorial 
func start() -> void:
	if started:
		return
	started = true
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property($CanvasModulate, "color", Color(1, 1, 1, 1), 1)
	tween.tween_property($UI/LabelStart, "modulate:a", 0, 1.5)
	
	# TODO: change amount
	for i in 1:
		await get_tree().create_timer(2).timeout
		character_new_spawn()
	
	await get_tree().create_timer(4).timeout
	canvas_dim(true)
	
	var tween_info: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_info.tween_property($UI/LabelInfo, "modulate:a", 1, 1)
	
	var tween_arrow: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween_arrow.tween_property($UI/SpriteArrow, "modulate:a", 1, 0.5)
	tween_arrow.tween_property($UI/SpriteArrow, "modulate:a", 0.5, 0.5)
	
	var character_first: Character = characters[0]
	character_first.material = MATERIAL_UNSHADED
	
	var tween_character: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween_character.tween_property(character_first, "modulate:a", 1, 0.5)
	tween_character.tween_property(character_first, "modulate:a", 0.5, 0.5)
	
	await tutorial_over
	tween_arrow.stop()
	tween_character.stop()
	
	await get_tree().create_timer(1).timeout
	
	# Audio
	audio_music.play()
	var tween_music: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_music.tween_property(audio_music, "volume_db", 0, 2)
	
	await get_tree().create_timer(1).timeout
	canvas_dim(false)
	
	
	tween_arrow = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_arrow.tween_property($UI/SpriteArrow, "modulate:a", 0, 1)
	tween_arrow.finished.connect(func() -> void:
		tween_arrow.kill()
		)
	
	tween_character = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_character.tween_property(character_first, "modulate:a", 1, 1)
	tween_character.finished.connect(func() -> void:
		tween_character.kill()
		character_first.material = null
		)
	
	for i in 2:
		await get_tree().create_timer(2).timeout
		character_new_spawn()
	
	timer_restart.timeout.connect(automatic_restart)
	timer_restart.wait_time = TIMER_RESTART_TIME
	timer_restart.start()
	
	timer_cycle.timeout.connect(canvas_dim_cycle)
	timer_cycle.wait_time = TIMER_CYCLE_TIME
	timer_cycle.start()


## Spawns a new character
func character_new_spawn() -> void:
	var character = characters_preload.pick_random().instantiate()
	character.production.connect(_on_character_production)
	character.action_taken.connect(_on_character_action_taken)
	character.death.connect(_on_character_death)
	
	character.global_position = character_spawn
	#character.global_position = Vector2(100,100)
	
	# Find the first slot that doesn't contain a character reference
	# Assign to the array and assing an id based on the position in the array
	for i in characters.size():
		#print(characters[i])
		if characters[i] is not Character:
			characters[i] = character
			character.id = i
			break
	
	add_child(character)
	
	# Audio
	await get_tree().create_timer(1.7).timeout
	if not audio_character_arrive.playing:
		audio_character_arrive.play()
	
	# TODO: for door to change color with delay
	await get_tree().create_timer(2.3).timeout
	# Make correct door green
	$Dormitory.door_change(character.id, false)
	
	var amount: int = characters_amount()
	if amount >= 15:
		print("WON")
		# Game win
		canvas_dim(true)
		$UI.show_win()
		await get_tree().create_timer(10).timeout
		automatic_restart()


## Check how many characters are currently alive
## [returns count] the amount of characters alive
func characters_amount() -> int:
	var count: int = 0
	for i in characters.size():
		if characters[i] is Character:
			count += 1
	return count


## When night comes, and morning arrives
func night() -> void:
	# TODO: testing needed
	#return
	
	var characters_positions: Array = Array()
	characters_positions.resize(15)
	characters_positions.fill(0)
	
	var tween_info: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	$UI/LabelInfo.text = "Yö saapuu..."
	tween_info.tween_property($UI/LabelInfo, "modulate:a", 1, 1.5)
	
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	for i in characters.size():
		if characters[i] is Character:
			var character: Character = characters[i]
			# Save position
			characters_positions[i] = character.global_position
			# Doesn't affect arriving characters or characters that have not yet moved
			if character.input_prevent or character.first_action:
				character.input_prevent = true
				continue
			character.input_prevent = true
			character.timers_state_change(false)
			tween.tween_property(character, "global_position", Vector2($Dormitory.global_position.x + randi_range(-100, 100),
				$Dormitory.global_position.y + randi_range(-50, 50)), 1.5)
	
	canvas_dim(true)
	# TODO: AUDIO
	await get_tree().create_timer(7).timeout
	
	tween_info = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	$UI/LabelInfo.text = "Aamu sarastaa..."
	tween_info.tween_property($UI/LabelInfo, "modulate:a", 0, 3)
	
	await get_tree().create_timer(1.5).timeout
	
	canvas_dim(false)
	var tween_out: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	for i in characters.size():
		if characters[i] is Character:
			var character: Character = characters[i]
			# Doesn't affect arriving characters or characters that have not yet moved
			if character.first_action:
				character.input_prevent = false
				continue
			# Check if position was saved to prevent moving errors
			if not (typeof(characters_positions[i]) == TYPE_VECTOR2):
				continue
			# Bring back to previous position
			tween_out.tween_property(character, "global_position", characters_positions[i], 1.5)
			tween_out.finished.connect(func() -> void:
				character.input_prevent = false
				character.timers_state_change(true)
				)
	
	await get_tree().create_timer(1.5).timeout
	print("NIGHT FINISHED")


## Dims the canvasmodulate
## [param enabled] to dim or to bring back to normal
func canvas_dim(enabled: bool) -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if enabled:
		tween.tween_property($CanvasModulate, "color", canvas_tint, 1)
	else:
		tween.tween_property($CanvasModulate, "color", Color(1, 1, 1, 1), 1)


## Dims canvas by a small amount, when dimmed 3 times -> night
func canvas_dim_cycle() -> void:
	timer_cycle.stop()
	await night()
	await get_tree().create_timer(1).timeout
	timer_cycle.start()


## Restart the timer to restart the game
func _on_character_action_taken() -> void:
	if tutorial:
		tutorial = false
		await get_tree().create_timer(1).timeout
		$UI/LabelInfo.text = "Hyvä!"
		var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property($UI/LabelInfo, "modulate:a", 0, 3)
		tutorial_over.emit()
	
	timer_restart.start()


## When a character dies
## [param id] character's id
func _on_character_death(id: int) -> void:
	if not audio_character_death.playing:
		audio_character_death.play()
	
	characters[id] = 0
	# TODO: needs to be tested
	production_limit = int(production_limit * 0.6)
	$UI.update_label(production, production_limit)
	# Make correct door red
	$Dormitory.door_change(id, true)
	var amount: int = characters_amount()
	if amount <= 0:
		# Game lose
		canvas_dim(true)
		$UI.show_lose()
		
		# Audio
		var tween_music: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween_music.tween_property(audio_music, "volume_db", -30, 7)
		
		await get_tree().create_timer(10).timeout
		automatic_restart()


## When a characters works and produces value
## Increases production limit in correlation to current production
## [param value] value that is added to the total
func _on_character_production(value: int) -> void:
	production += value
	#print("PRODUCTION LIMIT: " + str(production_limit))
	if production >= production_limit:
		production_limit += int(production_limit * 0.8) #lerp(production, production + production_limit, 1)
		character_new_spawn()
		#print("NEW PRODUCTION LIMIT: " + str(production_limit))
	#print("PRODUCTION: " + str(production))
	$UI.update_label(production, production_limit)


## Automatically restarts the game
func automatic_restart() -> void:
	print("RESTARTING")
	get_tree().reload_current_scene()
