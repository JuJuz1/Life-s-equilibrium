extends Area2D
class_name Character
## Character management

## Signals
signal production(value: int) ## Emits to world when working

## Age group for the character
enum AgeGroup {CHILD, ADULT, ELDERLY}

## Used to move the character
var dragging: bool = false
## Offset to not snap character to mouse position when pressed the first time
var offset: Vector2 = Vector2.ZERO

## Attributes
var age: int = 0
var age_group: AgeGroup = AgeGroup.CHILD
var energy: int = 0
var disease: bool = false

## Timers
@onready var timer_age = $TimerAge
const TIMER_AGE_TIMEOUT: int = 4
var age_increase: int = 1

@onready var timer_energy = $TimerEnergy

@onready var timer_production = $TimerProduction
const TIMER_PRODUCTION_TIMEOUT: int = 5
#var production_value: int = 2

## Attribute to determine where character is located, affects other attributes
var facility: String = "null"

func _ready() -> void:
	timer_age.timeout.connect(age_add)
	timer_age.wait_time = TIMER_AGE_TIMEOUT
	timer_age.start()
	
	timer_production.timeout.connect(produce)
	timer_production.wait_time = TIMER_PRODUCTION_TIMEOUT


## Adds age to the character
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
	dragging = true
	offset = get_global_mouse_position() - position


## When not pressed
func _on_button_button_up() -> void:
	dragging = false


## When mouse hovers over the character
func _on_button_mouse_entered() -> void:
	$Sprite2D.modulate.a = 0.5


## When mouse leaves the area
func _on_button_mouse_exited() -> void:
	$Sprite2D.modulate.a = 1


## Called every frame
func _process(_delta) -> void:
	if dragging:
		position = get_global_mouse_position() - offset
