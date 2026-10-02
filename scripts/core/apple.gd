# Autor: Mateusz Bartoszewicz
class_name Apple
extends Area2D
## Jabłko do zebrania. Znika po dotknięciu przez gracza (sygnał picked z liczbą punktów)
## albo po upływie lifetime (wtedy po cichu, bez kary).
## Złote jabłko jest warte więcej, ale gnije szybciej.

signal picked(points: int)

const RADIUS: float = 14.0
const DEFAULT_LIFETIME_SECONDS: float = 5.0
const GOLDEN_POINTS: int = 5
const GOLDEN_LIFETIME_FACTOR: float = 0.6
const FRESH_COLOR: Color = Color(0.85, 0.12, 0.12)
const ROTTEN_COLOR: Color = Color(0.45, 0.28, 0.12)
const GOLDEN_COLOR: Color = Color(1.0, 0.8, 0.1)
const GOLDEN_CORE_COLOR: Color = Color(1.0, 0.95, 0.6)

## Ustawiane przez Main przy tworzeniu, zanim jabłko trafi do drzewa.
@export var lifetime: float = DEFAULT_LIFETIME_SECONDS

var points: int = 1
var _age: float = 0.0
var _golden: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	# Kolor przechodzi ze świeżego w zgniły, więc gracz widzi, ile jabłku zostało.
	queue_redraw()


func _draw() -> void:
	if _golden:
		draw_circle(Vector2.ZERO, RADIUS, GOLDEN_COLOR)
		draw_circle(Vector2.ZERO, RADIUS * 0.5, GOLDEN_CORE_COLOR)
		return
	var rot: float = clampf(_age / lifetime, 0.0, 1.0)
	draw_circle(Vector2.ZERO, RADIUS, FRESH_COLOR.lerp(ROTTEN_COLOR, rot))


## Zamienia jabłko w złote. Wołać po ustawieniu lifetime, przed dodaniem do drzewa.
func make_golden() -> void:
	_golden = true
	points = GOLDEN_POINTS
	lifetime *= GOLDEN_LIFETIME_FACTOR


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		picked.emit(points)
		queue_free()
