# Autor: Mateusz Bartoszewicz
class_name Apple
extends Area2D
## Jabłko do zebrania. Znika po dotknięciu przez gracza (sygnał picked)
## albo po upływie LIFETIME_SECONDS (wtedy po cichu, bez kary).

signal picked

const RADIUS: float = 14.0
const LIFETIME_SECONDS: float = 5.0
const FRESH_COLOR: Color = Color(0.85, 0.12, 0.12)
const ROTTEN_COLOR: Color = Color(0.45, 0.28, 0.12)

var _age: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME_SECONDS:
		queue_free()
		return
	# Kolor przechodzi ze świeżego w zgniły, więc gracz widzi, ile jabłku zostało.
	queue_redraw()


func _draw() -> void:
	var rot: float = clampf(_age / LIFETIME_SECONDS, 0.0, 1.0)
	draw_circle(Vector2.ZERO, RADIUS, FRESH_COLOR.lerp(ROTTEN_COLOR, rot))


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		picked.emit()
		queue_free()
