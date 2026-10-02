# Autor: Mateusz Bartoszewicz
extends Node2D
## Mikrogra "zbieracz jabłek": zbieraj jabłka, zanim zgniją. Runda trwa ROUND_SECONDS.
## Cała logika rundy jest tutaj. Hud tylko wyświetla to, co dostanie przez sygnały.

signal score_changed(score: int)
signal time_left_changed(seconds: int)
signal round_started
signal round_finished(score: int)

const APPLE_SCENE: PackedScene = preload("res://scenes/world/apple.tscn")
const ROUND_SECONDS: int = 60
const MAX_APPLES: int = 8
const ARENA_MARGIN: float = 40.0
const MIN_SPAWN_DISTANCE: float = 96.0
const SPAWN_ATTEMPTS: int = 10
const BACKGROUND_COLOR: Color = Color(0.36, 0.55, 0.28)

var _score: int = 0
var _time_left: float = 0.0
var _playing: bool = false

@onready var _apples: Node2D = $Apples
@onready var _player: Player = $Player
@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _hud: Hud = $Hud


func _ready() -> void:
	score_changed.connect(_hud.set_score)
	time_left_changed.connect(_hud.set_time_left)
	round_started.connect(_hud.hide_message)
	round_finished.connect(_hud.show_game_over)
	_spawn_timer.timeout.connect(_spawn_apple)
	# Tło rysujemy po rozmiarze okna, więc przy jego zmianie trzeba odrysować.
	get_viewport().size_changed.connect(queue_redraw)
	_start_round()


func _process(delta: float) -> void:
	if not _playing:
		# Najprostszy restart: wczytanie sceny od nowa zeruje cały stan.
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return
	var previous_seconds: int = ceili(_time_left)
	_time_left = maxf(_time_left - delta, 0.0)
	var seconds: int = ceili(_time_left)
	if seconds != previous_seconds:
		time_left_changed.emit(seconds)
	if _time_left <= 0.0:
		_finish_round()


func _draw() -> void:
	draw_rect(get_viewport_rect(), BACKGROUND_COLOR)


func _start_round() -> void:
	_score = 0
	_time_left = float(ROUND_SECONDS)
	_playing = true
	_player.position = get_viewport_rect().get_center()
	_player.set_active(true)
	_spawn_timer.start()
	score_changed.emit(_score)
	time_left_changed.emit(ROUND_SECONDS)
	round_started.emit()


func _finish_round() -> void:
	_playing = false
	_spawn_timer.stop()
	_player.set_active(false)
	for apple in _apples.get_children():
		apple.queue_free()
	round_finished.emit(_score)


func _spawn_apple() -> void:
	if _apples.get_child_count() >= MAX_APPLES:
		return
	var apple: Apple = APPLE_SCENE.instantiate() as Apple
	apple.position = _random_spawn_position()
	apple.picked.connect(_on_apple_picked)
	_apples.add_child(apple)


# Losuje punkt na arenie, ale nie pod graczem, żeby jabłko nie liczyło się od razu.
func _random_spawn_position() -> Vector2:
	var area: Rect2 = get_viewport_rect().grow(-ARENA_MARGIN)
	var candidate: Vector2 = area.get_center()
	for _attempt in range(SPAWN_ATTEMPTS):
		candidate = Vector2(
			randf_range(area.position.x, area.end.x), randf_range(area.position.y, area.end.y)
		)
		if candidate.distance_to(_player.position) >= MIN_SPAWN_DISTANCE:
			break
	return candidate


func _on_apple_picked() -> void:
	if not _playing:
		return
	_score += 1
	score_changed.emit(_score)
