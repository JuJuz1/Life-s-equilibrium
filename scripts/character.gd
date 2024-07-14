extends Area2D
class_name Character
## Character management

## Signals
signal production(value: int) ## Emits to world when working
signal action_taken ## Emits to world when taking any action
signal death(id: int) ## Emits to world when a character dies

## Preload different faces
const FACE_BASE: CompressedTexture2D = preload("res://graphics/face_base.png")
const FACE_BASE_ENERGY_LOW: CompressedTexture2D = preload("res://graphics/face_base_energy_low.png")
const FACE_BASE_SICK: CompressedTexture2D = preload("res://graphics/face_base_sick.png")

## Age group for the character
enum AgeGroup {
	CHILD, 
	ADULT, 
	ELDERLY,
	}

## Displayed when energy levels are low
const energy_messages: Array[String] = [
	"Alkaa jo tämä työ painamaan...",
	"Nyt on energiatasot vähissä...",
	"Huhhuh... millonka tämä loppuu...",
]

## Displayed when character gets sick
const sickness_messages: Array[String] = [
	"Nyt ei olo tunnu hyvältä...",
	"Päähän koskee ja mikään ei onnistu...",
	"Nyt pitäisi päästä sairaalaan...",
]

## Displayed when character already was sick and still is
const sickness_and_was_sick_message: String = "Vieläkin on huono olo..."

## Displayed when character gets cured
const cured_messages: Array[String] = [
	"Nyt on olo paljon parempi...",
]

## When character dies
const death_message: String = "Nyt pääsen taivaaseen..."

## Used to move the character
var dragging: bool = false
## Offset to not snap character to mouse position when pressed the first time
var offset: Vector2 = Vector2.ZERO
## Used to determine when tweening/animating anything to prevent user action
var input_prevent: bool = false

## Attributes
var id: int
var age: int
var age_group: AgeGroup = AgeGroup.CHILD
var energy: int = 100
var sickness: bool = false

## Timers
## Age
@onready var timer_age = $TimerAge
const TIMER_AGE_TIMEOUT: int = 4
var age_increase: int = 1

## Energy level
@onready var timer_energy = $TimerEnergy
const TIMER_ENERGY_TIMEOUT: int = 3
var energy_change: int = -1

## Production
@onready var timer_production = $TimerProduction
const TIMER_PRODUCTION_TIMEOUT: int = 5
#var production_value: int = 2

## Sickness
@onready var timer_sickness: Timer = $TimerSickness
const TIMER_SICKNESS_TIMEOUT: int = 10 # TODO: change

## Attribute to determine where character is located, affects other attributes
var facility: String = "null"

func _ready() -> void:
	# TODO: testing
	#age = randi_range(10, 30)
	age = 55
	$Labels.labels_update(age, energy)
	
	# To prevent input
	input_prevent = true
	await get_tree().create_timer(1).timeout
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	# TODO: tweak
	tween.tween_property(self, "position:x", position.x + 435, 2)
	tween.tween_property(self, "position:y", position.y + 170, 1)
	tween.finished.connect(func() -> void:
		await get_tree().create_timer(1).timeout
		input_prevent = false
		# Start the timers
		timers_start()
		)


## Start all timers
func timers_start() -> void:
	timer_age.timeout.connect(age_add)
	timer_age.wait_time = TIMER_AGE_TIMEOUT
	timer_age.start()
	
	timer_energy.timeout.connect(energy_amend)
	timer_energy.wait_time = TIMER_ENERGY_TIMEOUT
	timer_energy.start()
	
	timer_production.timeout.connect(produce)
	timer_production.wait_time = TIMER_PRODUCTION_TIMEOUT
	
	timer_sickness.timeout.connect(sickness_check)
	timer_sickness.wait_time = TIMER_SICKNESS_TIMEOUT
	timer_sickness.start()


## Adds age to the character, dependent on the current facility (ex. workplace increases the amount)
func age_add() -> void:
	age += age_increase
	if age >= 50:
		age_group = AgeGroup.ELDERLY
	elif age >= 18:
		age_group = AgeGroup.ADULT
	else:
		age_group = AgeGroup.CHILD
	#print(age)
	#print(AgeGroup.keys()[age_group])
	$Labels.labels_update(age, energy)


## Changes to energy levels, dependent on the facility
func energy_amend() -> void:
	energy += energy_change
	if energy > 100:
		energy = 100
	if energy < 0:
		energy = 0
	# TODO: for testing
	if energy < 95:
		if not sickness:
			$Sprite2D.texture = FACE_BASE_ENERGY_LOW
		# Show message in sickness_check, otherwise too many
		#$Labels.state_label_show(energy_messages.pick_random())
	else:
		if not sickness:
			$Sprite2D.texture = FACE_BASE
	#print(energy)
	$Labels.labels_update(age, energy)


## Checks and calculates probability to become sick, emits death if already sick and probability hits
func sickness_check() -> void:
	# Only elderly can die for now
	if not (age_group == AgeGroup.ELDERLY):
		return
	
	"""
	if sickness:
		death.emit(id)
		print("death")
		queue_free()
		return
	"""
	
	# Used to determine if message should be shown
	var was_sick: bool = sickness
	
	var random = randf_range(0, 1)
	var age_probability: float = float(age) / 100
	print("RANDOM: " + str(random))
	print("AGE PROBABILITY: " + str(age_probability))
	
	# If not inside hospital -> gets sickness more often and higher chance to die to sickness
	# Else -> lower chance to get sick, lower chance to die and small chance to cure
	
	
	# TODO: seems ok maybe, needs thorough testing
	# Not inside hospital
	if not (facility == "hospital"):
		if sickness:
			if random < age_probability - 0.2: # ex. age is 40 -> 20%, 80 -> 60%
				_death()
				return
		else:
			if random < age_probability - 0.1: # example: if age is 50 -> 40%, if age_probability > 1.1 -> always sick (age > 110)
				sickness = true
				print_debug("sick")
	
	# Inside hospital
	else:
		if sickness:
			if random < age_probability - 0.4: # ex. 60 -> 20%, 90 -> 50%
				_death()
				return
			elif random > age_probability - 0.2: # ex. 20 -> 100%, 60 -> 60%, 100 -> 20%
				sickness = false
				print_debug("cured")
		else:
			if random < age_probability * 0.5: # Half of age ex. 60 -> 30%
				sickness = true
				print_debug("sick")
	
	# If character gets sick or already was sick
	if sickness:
		if not was_sick: # If character gets sick
			# TODO: for testing
			$Sprite2D.texture = FACE_BASE_SICK
			$Labels.state_label_show(sickness_messages.pick_random())
		else: # If character was already sick
			$Labels.state_label_show(sickness_and_was_sick_message)
	# If was sick and was cured
	elif was_sick and not sickness:
		$Sprite2D.texture = FACE_BASE
		$Labels.state_label_show(cured_messages.pick_random())
	# If healthy 
	# ELSE?
	elif not was_sick and not sickness:
		if energy < 95:
			$Labels.state_label_show(energy_messages.pick_random())


## When character dies to sickness
func _death() -> void:
		print("death")
		$Labels.state_label_show(death_message)
		# TODO: comment in :D
		death.emit(id)
		input_prevent = true
		var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(self, "modulate:a", 0, 3)
		await tween.finished
		queue_free()


## Start or disable production when entering or leaving workplace
## [param enabled] state
func production_state_change(enabled: bool) -> void:
	if enabled:
		timer_production.start()
		#print_debug("PRODUCTION START")
	else:
		timer_production.stop()
		#print_debug("PRODUCTION STOP")


## Produced value when working
func produce() -> void:
	var value: int = 0
	match age_group:
		AgeGroup.CHILD: value = 1
		AgeGroup.ADULT: value = 2
		AgeGroup.ELDERLY: value = 3
	production.emit(value)


## When pressed down
func _on_button_button_down() -> void:
	if input_prevent:
		return
	dragging = true
	offset = get_global_mouse_position() - position
	# Emit to reset timer to restart the game
	action_taken.emit()


## When not pressed
func _on_button_button_up() -> void:
	dragging = false


## When mouse hovers over the character
func _on_button_mouse_entered() -> void:
	if input_prevent:
		return
	$Sprite2D.modulate.a = 0.5


## When mouse leaves the area
func _on_button_mouse_exited() -> void:
	$Sprite2D.modulate.a = 1


## Called every frame, used to move the character
func _process(_delta) -> void:
	# For good measure
	if input_prevent:
		return
	if dragging:
		position = get_global_mouse_position() - offset
