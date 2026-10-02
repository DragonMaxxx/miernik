# miernik

Gra 2D top-down w stylu Stardew Valley (oryginalna), w Godot 4 i GDScript. Tytuł roboczy: miernik (nazwa repo, **DO USTALENIA**).

Ustalenia, architektura i konwencje: [`CLAUDE.md`](CLAUDE.md). Szkic projektu gry: [`docs/gdd.md`](docs/gdd.md).

## Uruchomienie

Wymagany Godot 4.3 lub nowszy (potrzebny `TileMapLayer`). Dokładna wersja jest **DO USTALENIA**.

```bash
git lfs install            # jednorazowo, pliki binarne idą przez Git LFS
godot --path .             # uruchomienie
godot --headless --path . --quit   # szybki test, czy projekt się ładuje
```

Nazwa binarki zależy od instalacji (`godot`, `godot4` lub ścieżka do pliku). Możesz też otworzyć projekt w edytorze (Import → `project.godot`).

## Mikrogra: zbieracz jabłek (krok 0 planu)

Widok z góry: zbieraj jabłka, zanim zgniją (czerwone → brązowe). Runda trwa 60 s.

- **Tempo rośnie:** w trakcie rundy jabłka pojawiają się coraz częściej i gniją coraz szybciej.
- **Złote jabłko** (12% szans) daje 5 punktów, ale gnije szybciej.
- **Kombo:** kolejne jabłko zebrane w ciągu 1,5 s od poprzedniego podbija mnożnik punktów (do x5). Po przerwie kombo wygasa.
- **Sterowanie:** WASD lub strzałki (akcje `move_*` w `project.godot`), Esc to pauza, Enter lub spacja po końcu rundy to restart.
- Grafika to klocki rysowane w `_draw()`, bez assetów. Stałe do dostrojenia są na górze skryptów (`main.gd`, `apple.gd`, `player.gd`).
- Sceny: `scenes/world/main.tscn` (start), `scenes/player/player.tscn`, `scenes/world/apple.tscn`, `scenes/ui/hud.tscn`.

## Struktura

```
assets/{art,audio,fonts}
data/{items,crops,recipes}      # Resources .tres
scenes/{player,world,ui,npc}
scripts/{core,systems,ui}
docs/gdd.md
```

## Code review agenta

- `.github/workflows/claude-review.yml` robi review każdego PR (poza draftami), według zasad z `CLAUDE.md`, sekcja 13.
- `.github/workflows/claude.yml` odpowiada na `@claude` w komentarzach do PR-ów i issue.

Wymagana konfiguracja:

1. Zainstaluj [Claude GitHub App](https://github.com/apps/claude) na repo.
2. Dodaj sekret `ANTHROPIC_API_KEY` w Settings → Secrets and variables → Actions.
3. Pliki workflow muszą być na domyślnym branchu repo (docelowo `main`). Akcja odrzuca workflow, którego treść różni się od wersji na domyślnym branchu.
4. Na PR-ach z forków sekrety nie są dostępne, więc review tam nie zadziała.
