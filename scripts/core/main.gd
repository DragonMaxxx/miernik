# Autor: Mateusz Bartoszewicz
extends Node2D
## Mikrogra "zbieracz jabłek": zbieraj jabłka, zanim zgniją. Runda trwa ROUND_SECONDS.
## Tempo rośnie w trakcie rundy, jabłka zebrane w krótkich odstępach dają kombo,
## a złote są warte więcej. Cała logika rundy jest tutaj, Hud tylko wyświetla
## to, co dostanie przez sygnały.

signal score_changed(score: int)
signal time_left_changed(seconds: int)
signal combo_changed(combo: int)
signal paused_changed(paused: bool)
signal round_started
signal round_finished(score: int)

const APPLE_SCENE: PackedScene = preload("res://scenes/world/apple.tscn")
const ROUND_SECONDS: int = 60
const MAX_APPLES: int = 8
const ARENA_MARGIN: float = 40.0
const MIN_SPAWN_DISTANCE: float = 96.0
const SPAWN_ATTEMPTS: int = 10
# Tempo: odstęp między jabłkami i ich czas życia zmieniają się liniowo
# od wartości początkowej do końcowej w ciągu rundy.
const SPAWN_INTERVAL_START: float = 0.9
const SPAWN_INTERVAL_END: float = 0.4
const LIFETIME_START: float = 5.0
const LIFETIME_END: float = 2.5
const GOLDEN_CHANCE: float = 0.12
const COMBO_WINDOW_SECONDS: float = 1.5
const COMBO_MAX: int = 5
const BACKGROUND_COLOR: Color = Color(0.36, 0.55, 0.28)

var _score: int = 0
var _time_left: float = 0.0
var _playing: bool = false
var _combo: int = 0
var _combo_time_left: float = 0.0

@onready var _apples: Node2D = $Apples
@onready var _player: Player = $Player
@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _hud: Hud = $Hud


func _ready() -> void:
	# Main musi działać także podczas pauzy (obsługuje wyjście z niej), a dzieci
	# dziedziczą tryb po rodzicu, więc to, co ma stanąć, oznaczamy jawnie.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apples.process_mode = Node.PROCESS_MODE_PAUSABLE
	_player.process_mode = Node.PROCESS_MODE_PAUSABLE
	_spawn_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	score_changed.connect(_hud.set_score)
	time_left_changed.connect(_hud.set_time_left)
	combo_changed.connect(_hud.set_combo)
	paused_changed.connect(_hud.set_paused)
	round_started.connect(_hud.hide_message)
	round_finished.connect(_hud.show_game_over)
	_spawn_timer.timeout.connect(_spawn_apple)
	# Tło rysujemy po rozmiarze okna, więc przy jego zmianie trzeba odrysować.
	get_viewport().size_changed.connect(queue_redraw)
	_start_round()


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if not _playing:
		# Najprostszy restart: wczytanie sceny od nowa zeruje cały stan.
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return
	_tick_clock(delta)
	_tick_combo(delta)


func _unhandled_input(event: InputEvent) -> void:
	if _playing and event.is_action_pressed("ui_cancel"):
		_set_paused(not get_tree().paused)


func _draw() -> void:
	draw_rect(get_viewport_rect(), BACKGROUND_COLOR)


func _start_round() -> void:
	_score = 0
	_time_left = float(ROUND_SECONDS)
	_playing = true
	_combo = 0
	_combo_time_left = 0.0
	_player.position = get_viewport_rect().get_center()
	_player.set_active(true)
	_spawn_timer.wait_time = SPAWN_INTERVAL_START
	_spawn_timer.start()
	score_changed.emit(_score)
	time_left_changed.emit(ROUND_SECONDS)
	combo_changed.emit(_combo)
	round_started.emit()


func _finish_round() -> void:
	_playing = false
	_spawn_timer.stop()
	_player.set_active(false)
	for apple in _apples.get_children():
		apple.queue_free()
	_combo = 0
	combo_changed.emit(_combo)
	round_finished.emit(_score)


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	paused_changed.emit(paused)


func _tick_clock(delta: float) -> void:
	var previous_seconds: int = ceili(_time_left)
	_time_left = maxf(_time_left - delta, 0.0)
	var seconds: int = ceili(_time_left)
	if seconds != previous_seconds:
		time_left_changed.emit(seconds)
	if _time_left <= 0.0:
		_finish_round()


func _tick_combo(delta: float) -> void:
	if _combo == 0:
		return
	_combo_time_left -= delta
	if _combo_time_left <= 0.0:
		_combo = 0
		combo_changed.emit(_combo)


# 0.0 na początku rundy, 1.0 na jej końcu.
func _difficulty() -> float:
	return clampf(1.0 - _time_left / float(ROUND_SECONDS), 0.0, 1.0)


func _spawn_apple() -> void:
	var difficulty: float = _difficulty()
	# Timer przejmuje nowy odstęp od następnego cyklu.
	_spawn_timer.wait_time = lerpf(SPAWN_INTERVAL_START, SPAWN_INTERVAL_END, difficulty)
	if _apples.get_child_count() >= MAX_APPLES:
		return
	var apple: Apple = APPLE_SCENE.instantiate() as Apple
	apple.position = _random_spawn_position()
	apple.lifetime = lerpf(LIFETIME_START, LIFETIME_END, difficulty)
	if randf() < GOLDEN_CHANCE:
		apple.make_golden()
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


func _on_apple_picked(points: int) -> void:
	if not _playing:
		return
	# Kolejne jabłko w oknie czasowym podbija mnożnik, po jego upływie kombo wygasa.
	_combo = mini(_combo + 1, COMBO_MAX)
	_combo_time_left = COMBO_WINDOW_SECONDS
	_score += points * _combo
	combo_changed.emit(_combo)
	score_changed.emit(_score)
