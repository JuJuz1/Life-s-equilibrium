extends Area2D
class_name Character
## Character management

## Signals
signal production(value: int) ## Emits to world when working
signal action_taken ## Emits to world when taking any action
signal death(id: int) ## Emits to world when a character dies

## Age group for the character
enum AgeGroup {
	CHILD, 
	ADULT, 
	ELDERLY,
	}

## Used to move the character
var dragging: bool = false
## Offset to not snap character to mouse position when pressed the first time
var offset: Vector2 = Vector2.ZERO
## Used to determine when tweening/animation to prevent user action
var animation: bool = false

## Attributes
var id: int
var age: int
var age_group: AgeGroup = AgeGroup.CHILD
var energy: int = 100
var sick: bool = false

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

## Attribute to determine where character is located, affects other attributes
var facility: String = "null"

func _ready() -> void:
	timer_age.timeout.connect(age_add)
	timer_age.wait_time = TIMER_AGE_TIMEOUT
	timer_age.start()
	
	timer_energy.timeout.connect(energy_amend)
	timer_energy.wait_time = TIMER_ENERGY_TIMEOUT
	timer_energy.start()
	
	timer_production.timeout.connect(produce)
	timer_production.wait_time = TIMER_PRODUCTION_TIMEOUT
	
	age = randi_range(10, 30)
	$Labels.labels_update(age, energy)
	
	# TODO: for testing
	#return
	
	animation = true
	await get_tree().create_timer(1).timeout
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position:x", position.x + 250, 1.5)
	tween.tween_property(self, "position:y", position.y + 125, 1)
	tween.finished.connect(func() -> void:
		await get_tree().create_timer(0.5).timeout
		animation = false)


## Adds age to the character, dependent on the current facility (ex. workplace increases the amount)
func age_add() -> void:
	age += age_increase
	if age >= 50:
		age_group = AgeGroup.ELDERLY
	elif age >= 18:
		age_group = AgeGroup.ADULT
	else:
		age_group = AgeGroup.CHILD
	print(age)
	print(AgeGroup.keys()[age_group])
	$Labels.labels_update(age, energy)


## Changes to energy levels, dependent on the facility
func energy_amend() -> void:
	energy += energy_change
	if energy > 100:
		energy = 100
	if energy < 0:
		energy = 0
	print(energy)
	$Labels.labels_update(age, energy)


## Start or disable production when entering or leaving workplace
## [param enabled] state
func production_state_change(enabled: bool) -> void:
	if enabled:
		timer_production.start()
		print_debug("PRODUCTION START")
	else:
		timer_production.stop()
		print_debug("PRODUCTION STOP")


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
	if animation:
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
	if animation:
		return
	$Sprite2D.modulate.a = 0.5


## When mouse leaves the area
func _on_button_mouse_exited() -> void:
	$Sprite2D.modulate.a = 1


## Called every frame, used to move the character
func _process(_delta) -> void:
	if dragging:
		position = get_global_mouse_position() - offset
